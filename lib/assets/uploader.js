
function setApplicationName(name, version) {
  window.apiVideoFlutterUploader.params.application = {
    name,
    version
  }
}

function setChunkSize(chunkSize) {
  window.apiVideoFlutterUploader.params.chunkSize = chunkSize;
}

function getProgressiveSession(sessionId) {
  return window.apiVideoFlutterUploader.progressiveSessions[sessionId];
}

function setProgressiveSession(sessionId, progressiveSession) {
  window.apiVideoFlutterUploader.progressiveSessions = window.apiVideoFlutterUploader.progressiveSessions || {};
  window.apiVideoFlutterUploader.progressiveSessions[sessionId] = progressiveSession;
}

function storeStandardUploader(uploader) {
  window.apiVideoFlutterUploader.standardUploaders = window.apiVideoFlutterUploader.standardUploaders || [];
  window.apiVideoFlutterUploader.standardUploaders.push(uploader);
}

function createProgressiveUploadWithUploadTokenSession(sessionId, uploadToken, videoId) {
  return progressiveUploadCreationHelper({
    sessionId,
    uploadToken,
    videoId: videoId || undefined,
  });
}

function createProgressiveUploadWithApiKeySession(sessionId, apiKey, videoId) {
  return progressiveUploadCreationHelper({
    sessionId,
    apiKey,
    videoId: videoId || undefined,
  });
}

async function uploadPart(sessionId, filePath, onProgress) {
  return await uploadPartHelper(sessionId, filePath, onProgress, async (session, blob) => {
    return await session.uploader.uploadPart(blob);
  });
}

async function uploadLastPart(sessionId, filePath, onProgress) {
  return await uploadPartHelper(sessionId, filePath, onProgress, async (session, blob) => {
    return await session.uploader.uploadLastPart(blob);
  });
}

async function getBlobFromPath(filePath) {
  return await fetch(filePath)
    .then(r => r.blob());
}

async function cancelAll() {
  const sessions = window.apiVideoFlutterUploader.progressiveSessions;
  if (sessions != null) {
    Object.values(sessions).forEach(session => {
      session.uploader.cancel();
    });
  }

  const standardUploaders = window.apiVideoFlutterUploader.standardUploaders;
  if (standardUploaders != null) {
    standardUploaders.forEach(uploader => {
      uploader.cancel();
    });
  }
}

async function jsDisposeProgressiveUploadSession(sessionId) {
  const session = getProgressiveSession(sessionId);
  if (session != null) {
    delete window.apiVideoFlutterUploader.progressiveSessions[sessionId];
  }
}

async function uploadWithUploadToken(filePath, uploadToken, videoName, onProgress, videoId) {
  return uploadHelper(filePath, onProgress, { uploadToken, videoName, videoId });
}

async function uploadWithApiKey(filePath, apiKey, onProgress, videoId) {
  return uploadHelper(filePath, onProgress, { apiKey, videoId });
}


function progressiveUploadCreationHelper(options) {
  const uploader = new ProgressiveUploader({
    ...options,
    origin: getOriginHeader(),
  });

  uploader.onProgress((e) => {
    const onProgress = getProgressiveSession(options.sessionId).partsOnProgress[e.part];
    if (onProgress) {
      onProgress(e.uploadedBytes / e.totalBytes);
    }
  });

  setProgressiveSession(options.sessionId, {
    uploader,
    partsOnProgress: {},
    currentPart: 1,
  });

  return Promise.resolve();
}

async function uploadPartHelper(sessionId, filePath, onProgress, uploadCallback) {
  const blob = await getBlobFromPath(filePath);
  const session = getProgressiveSession(sessionId);

  if (onProgress != null) {
    session.partsOnProgress[session.currentPart] = onProgress;
  }

  session.currentPart++;

  try {
    return JSON.stringify(await uploadCallback(session, blob));
  } catch (e) {
    throw new Error(e.title);
  }
}

async function uploadHelper(filePath, onProgress, options) {
  const blob = await getBlobFromPath(filePath);

  const uploader = new VideoUploader({
    file: blob,
    chunkSize: 1024 * 1024 * window.apiVideoFlutterUploader.params.chunkSize,
    origin: getOriginHeader(),
    ...options
  });

  storeStandardUploader(uploader);

  if (onProgress != null) {
    uploader.onProgress((e) => onProgress(e.uploadedBytes / e.totalBytes));
  }
  try {
    return JSON.stringify(await uploader.upload());
  } catch (e) {
    if (e.reason === "ABORTED") {
      throw new Error(e.reason);
    }
    throw new Error(e.title);
  }

}

function getOriginHeader() {
  return {
    sdk: {
      name: 'flutter-uploader',
      version: window.apiVideoFlutterUploader.params.sdkVersion,
    },
    application: window.apiVideoFlutterUploader.params.application
  };
}



// https://github.com/flutter/flutter/issues/126713
function fixRequireJs() {
  if (typeof window.define == 'function') {
    delete window.define.amd;
    delete window.exports;
    delete window.module;
  }
}