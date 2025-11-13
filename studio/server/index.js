import express from 'express';
import cors from 'cors';
import path from 'node:path';
import fs from 'node:fs/promises';
import { spawn } from 'node:child_process';

const PORT = Number(process.env.PORT || 4000);
const SUCCESS_EXIT_CODES = new Set([0, 10, 20, 30]);

const repoRoot = path.resolve(process.cwd(), '..');
const casperAppDir = path.join(repoRoot, 'app');
const casperResultsDir = path.join(repoRoot, 'results');
const casperExecutionScript = path.join(repoRoot, 'execution', 'run_casper.sh');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

async function ensureDirectory(dirPath) {
  const stats = await fs.stat(dirPath).catch(() => null);
  if (!stats || !stats.isDirectory()) {
    const error = new Error(`Directory not found: ${dirPath}`);
    error.statusCode = 404;
    throw error;
  }
}

async function listDirectories(dirPath) {
  await ensureDirectory(dirPath);
  const entries = await fs.readdir(dirPath, { withFileTypes: true });
  return entries.filter((entry) => entry.isDirectory()).map((entry) => entry.name);
}

async function listResultFiles(appName, mode) {
  const targetDir = path.join(casperResultsDir, appName, mode);
  await ensureDirectory(targetDir);
  const entries = await fs.readdir(targetDir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && entry.name.endsWith('.json'))
    .map((entry) => entry.name)
    .sort()
    .reverse();
}

async function getLatestResultFile(appName, mode) {
  const files = await listResultFiles(appName, mode);
  if (!files.length) {
    const error = new Error(`No result files found for ${appName}/${mode}`);
    error.statusCode = 404;
    throw error;
  }
  if (files.length === 1) return files[0];
  const targetDir = path.join(casperResultsDir, appName, mode);
  const filesWithTime = await Promise.all(
    files.map(async (file) => {
      const filePath = path.join(targetDir, file);
      const stats = await fs.stat(filePath);
      return { file, time: stats.mtimeMs };
    })
  );
  filesWithTime.sort((a, b) => b.time - a.time);
  return filesWithTime[0].file;
}

async function readResultJson(appName, mode, requestedFile) {
  const fileName = requestedFile ?? (await getLatestResultFile(appName, mode));
  const safeName = path.basename(fileName);
  const targetPath = path.join(casperResultsDir, appName, mode, safeName);
  const jsonBuffer = await fs.readFile(targetPath, 'utf8').catch((error) => {
    if (error.code === 'ENOENT') {
      const err = new Error(`Result file not found: ${safeName}`);
      err.statusCode = 404;
      throw err;
    }
    throw error;
  });
  try {
    return JSON.parse(jsonBuffer);
  } catch (error) {
    const err = new Error(`Failed to parse CASPER result JSON (${safeName})`);
    err.statusCode = 500;
    throw err;
  }
}

function inferRepairFlag(mode, explicit) {
  if (explicit === 'yes' || explicit === 'no') {
    return explicit;
  }
  return mode === 'naive' ? 'no' : 'yes';
}

function parseAdditionalParameters(parameterString) {
  if (!parameterString) return [];
  return parameterString
    .split(/\s+/)
    .map((chunk) => chunk.trim())
    .filter(Boolean);
}

function extractResultPath(stdout) {
  const match = stdout.match(/Results saved to (.+)/);
  if (match && match[1]) {
    return match[1].trim();
  }
  return null;
}

function runCasperProcess(args) {
  return new Promise((resolve, reject) => {
    const child = spawn('bash', [casperExecutionScript, ...args], {
      cwd: repoRoot,
      env: process.env,
    });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      const text = chunk.toString();
      stdout += text;
      process.stdout.write(text);
    });

    child.stderr.on('data', (chunk) => {
      const text = chunk.toString();
      stderr += text;
      process.stderr.write(text);
    });

    child.on('error', (error) => {
      reject(error);
    });

    child.on('close', (code) => {
      resolve({ code, stdout, stderr });
    });
  });
}

app.get(
  '/api/apps',
  asyncHandler(async (_req, res) => {
    const apps = await listDirectories(casperAppDir);
    res.json({ apps });
  })
);

app.get(
  '/api/results/files',
  asyncHandler(async (req, res) => {
    const appName = req.query.app;
    const mode = req.query.mode;
    if (!appName || !mode) {
      res.status(400).json({ error: 'Missing required query params: app, mode' });
      return;
    }
    const files = await listResultFiles(appName, mode);
    res.json({ files });
  })
);

app.get(
  '/api/results',
  asyncHandler(async (req, res) => {
    const appName = (req.query.app || 'lung_cancer').toString();
    const mode = (req.query.mode || 'naive').toString();
    const fileName = req.query.file?.toString();
    const json = await readResultJson(appName, mode, fileName);
    res.json(json);
  })
);

app.post(
  '/api/run',
  asyncHandler(async (req, res) => {
    const body = req.body || {};
    const appName = body.appName || body.app || 'lung_cancer';
    const mode = body.mode || body.timeline || 'naive';
    if (!appName) {
      res.status(400).json({ error: 'Missing app name' });
      return;
    }
    const threads = Number(body.threads || body.threadCount || 1);
    const unit = body.unit || 'seconds';
    const repair = inferRepairFlag(mode, body.repair);
    const windowStart = body.windowStart ?? body.window?.start;
    const windowEnd = body.windowEnd ?? body.window?.end;
    const verbose = body.verbose === true || body.verbose === 'yes';
    const parameterString = body.parameters || '';

    const args = [`--app=${appName}`, `--timeline=${mode}`, `--thread-N=${threads}`, `--unit=${unit}`, `--repair=${repair}`];

    if (verbose) {
      args.push('--verbose');
    }

    if (windowStart !== undefined && windowEnd !== undefined) {
      args.push(`--window=${windowStart}-${windowEnd}`);
    }

    const extraArgs = parseAdditionalParameters(parameterString);
    args.push(...extraArgs);

    const result = await runCasperProcess(args);
    const success = SUCCESS_EXIT_CODES.has(result.code ?? -1);
    const outputPath = extractResultPath(result.stdout);

    res.status(success ? 200 : 500).json({
      success,
      exitCode: result.code,
      outputPath,
      stdout: result.stdout,
      stderr: result.stderr,
      args,
    });
  })
);

app.use((err, _req, res, _next) => {
  console.error(err);
  const status = err.statusCode || 500;
  res.status(status).json({ error: err.message || 'Internal Server Error' });
});

app.listen(PORT, () => {
  console.log(`CASPER backend listening on http://localhost:${PORT}`);
});
