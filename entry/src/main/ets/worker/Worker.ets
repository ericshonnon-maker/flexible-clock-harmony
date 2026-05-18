import worker from '@ohos.worker';
import hilog from '@ohos.hilog';

const TAG = 'ClockWorker';
const DOMAIN = 0x0002;

// Create a worker thread for background timing operations
const workerInstance = new worker.ThreadWorker('entry/src/main/ets/worker/Worker.ets');

// Handle messages from the main thread
workerInstance.onmessage = (event) => {
  hilog.info(DOMAIN, TAG, 'Worker received message: %{public}s', JSON.stringify(event.data));

  if (event.data.type === 'start') {
    // Start periodic timer in worker thread
    hilog.info(DOMAIN, TAG, 'Worker starting timer');
  } else if (event.data.type === 'stop') {
    // Stop timer
    hilog.info(DOMAIN, TAG, 'Worker stopping timer');
    workerInstance.terminate();
  }
};

// Handle worker errors
workerInstance.onerror = (error) => {
  hilog.error(DOMAIN, TAG, 'Worker error: %{public}s', JSON.stringify(error));
};

// Export the worker instance for use by main thread
export default workerInstance;
