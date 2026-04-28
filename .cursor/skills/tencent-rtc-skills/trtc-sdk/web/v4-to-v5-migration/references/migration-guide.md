# TRTC Web SDK v4 → v5 Migration Reference Guide

This is the authoritative reference for API and event mapping between v4 (`trtc-js-sdk`) and v5 (`trtc-sdk-v5`).

## Package Change

| Item | v4 | v5 |
|------|----|----|
| npm package | `trtc-js-sdk` | `trtc-sdk-v5` |
| Import | `import TRTC from 'trtc-js-sdk'` | `import TRTC from 'trtc-sdk-v5'` |

## Architecture Change

| Aspect | v4 | v5 |
|--------|----|----|
| Design | Client + Stream separated | Unified TRTC instance |
| Instance creation | `TRTC.createClient()` + `TRTC.createStream()` | `TRTC.create()` |
| Auth params location | In `createClient()` | In `enterRoom()` |
| Mode/Scene param | `mode: 'rtc'` in `createClient()` | `scene: 'rtc'` in `enterRoom()` |
| Remote stream handling | Manual subscribe + play | `startRemoteVideo()` auto-subscribes |
| Screen sharing | Create separate Stream + publish as auxiliary | `startScreenShare()` one-call |
| Statistics | Polling via `getXxxStats()` APIs | Event-driven via `STATISTICS` event |
| Plugin system | None | Unified plugin mechanism |
| Room switch | Leave + rejoin | `switchRoom()` |

## Complete API Mapping Table

| Feature | v4 API | v5 API |
|---------|--------|--------|
| Environment detection | `TRTC.checkSystemRequirements()` | `TRTC.isSupported()` |
| Create instance | `TRTC.createClient()` + `TRTC.createStream()` | `TRTC.create()` |
| Enter room | `client.join({ roomId })` | `trtc.enterRoom({ sdkAppId, userId, userSig, roomId, scene })` |
| Exit room | `client.leave()` | `trtc.exitRoom()` |
| Destroy instance | `client.destroy()` | `trtc.destroy()` |
| Switch room | Leave + rejoin | `trtc.switchRoom({ roomId })` |
| Initialize stream | `stream.initialize()` | _(integrated into startLocalVideo/startLocalAudio)_ |
| Play local stream | `stream.play(elementId)` | `view` param in `startLocalVideo()` |
| Publish stream | `client.publish(stream)` | `trtc.startLocalVideo()` + `trtc.startLocalAudio()` **必须同时调用** |
| Unpublish stream | `client.unpublish(stream)` | `trtc.stopLocalVideo()` / `trtc.stopLocalAudio()` |
| Close stream | `stream.close()` | `trtc.stopLocalVideo()` / `trtc.stopLocalAudio()` |
| Subscribe remote | `client.subscribe(stream)` | Audio: auto; Video: `trtc.startRemoteVideo()` |
| Unsubscribe remote | `client.unsubscribe(stream)` | `trtc.stopRemoteVideo()` / `trtc.muteRemoteAudio()` |
| Play remote stream | `stream.play(elementId)` | `view` param in `startRemoteVideo()` |
| Stop remote stream | `stream.stop()` | `trtc.stopRemoteVideo()` |
| Mute local audio | `stream.muteAudio()` | `trtc.updateLocalAudio({ mute: true })` |
| Unmute local audio | `stream.unmuteAudio()` | `trtc.updateLocalAudio({ mute: false })` |
| Mute local video | `stream.muteVideo()` | `trtc.updateLocalVideo({ mute: true })` |
| Unmute local video | `stream.unmuteVideo()` | `trtc.updateLocalVideo({ mute: false })` |
| Set video profile | `stream.setVideoProfile(profile)` | `trtc.startLocalVideo({ option: { profile } })` or `trtc.updateLocalVideo({ option: { profile } })` |
| Set audio profile | `stream.setAudioProfile(profile)` | `trtc.startLocalAudio({ option: { profile } })` or `trtc.updateLocalAudio({ option: { profile } })` |
| Switch camera | `stream.switchDevice('video', cameraId)` | `trtc.updateLocalVideo({ option: { cameraId } })` |
| Switch microphone | `stream.switchDevice('audio', micId)` | `trtc.updateLocalAudio({ option: { microphoneId: micId } })` |
| Screen share (start) | `createStream({screen:true})` + `initialize()` + `client.publish(stream, {isAuxiliary:true})` | `trtc.startScreenShare()` |
| Screen share (stop) | `client.unpublish(shareStream)` + `shareStream.close()` | `trtc.stopScreenShare()` |
| Switch role | `client.switchRole('anchor'/'audience')` | `trtc.switchRole(TRTC.TYPE.ROLE_ANCHOR / TRTC.TYPE.ROLE_AUDIENCE)` |
| Volume evaluation | `client.enableAudioVolumeEvaluation(interval)` | `trtc.enableAudioVolumeEvaluation(interval)` |
| Get cameras | `TRTC.getCameras()` | `TRTC.getCameraList()` |
| Get microphones | `TRTC.getMicrophones()` | `TRTC.getMicrophoneList()` |
| Get speakers | `TRTC.getSpeakers()` | `TRTC.getSpeakerList()` |
| Get all devices | `TRTC.getDevices()` | _(removed, use individual list APIs)_ |
| Transport stats | `client.getTransportStats()` | `TRTC.EVENT.STATISTICS` event (`rtt`, `upLoss`, `downLoss`) |
| Local audio stats | `client.getLocalAudioStats()` | `TRTC.EVENT.STATISTICS` event (`localStatistics.audio`) |
| Local video stats | `client.getLocalVideoStats()` | `TRTC.EVENT.STATISTICS` event (`localStatistics.video`) |
| Remote audio stats | `client.getRemoteAudioStats()` | `TRTC.EVENT.STATISTICS` event (`remoteStatistics[].audio`) |
| Remote video stats | `client.getRemoteVideoStats()` | `TRTC.EVENT.STATISTICS` event (`remoteStatistics[].video`) |
| SEI message (send) | `client.sendSEIMessage(buffer)` | `trtc.sendSEIMessage(buffer)` |
| Enable small stream | `client.enableSmallStream()` + `client.setSmallStreamProfile({...})` | `trtc.startLocalVideo({ option: { small: { width, height, bitrate, frameRate } } })` |
| Subscribe small stream | `client.setRemoteVideoStreamType(stream, 'small')` | `trtc.startRemoteVideo({ userId, streamType: TRTC.TYPE.STREAM_TYPE_MAIN, option: { small: true } })` |
| Custom message | _(not available)_ | `trtc.sendCustomMessage({ cmdId, data })` |

## Complete Event Mapping Table

| Feature | v4 Event String | v5 Event Constant |
|---------|----------------|-------------------|
| Remote stream available | `'stream-added'` | `TRTC.EVENT.REMOTE_VIDEO_AVAILABLE` / `TRTC.EVENT.REMOTE_AUDIO_AVAILABLE` |
| Remote stream subscribed | `'stream-subscribed'` | _(removed — handled internally by startRemoteVideo)_ |
| Remote stream removed | `'stream-removed'` | `TRTC.EVENT.REMOTE_VIDEO_UNAVAILABLE` / `TRTC.EVENT.REMOTE_AUDIO_UNAVAILABLE` |
| Remote stream updated | `'stream-updated'` | _(no direct equivalent)_ |
| Remote user enter | `'peer-join'` | `TRTC.EVENT.REMOTE_USER_ENTER` |
| Remote user exit | `'peer-leave'` | `TRTC.EVENT.REMOTE_USER_EXIT` |
| Remote mute audio | `'mute-audio'` | `TRTC.EVENT.REMOTE_AUDIO_UNAVAILABLE` |
| Remote unmute audio | `'unmute-audio'` | `TRTC.EVENT.REMOTE_AUDIO_AVAILABLE` |
| Remote mute video | `'mute-video'` | `TRTC.EVENT.REMOTE_VIDEO_UNAVAILABLE` |
| Remote unmute video | `'unmute-video'` | `TRTC.EVENT.REMOTE_VIDEO_AVAILABLE` |
| Kicked out | `'client-banned'` | `TRTC.EVENT.KICKED_OUT` |
| Network quality | `'network-quality'` | `TRTC.EVENT.NETWORK_QUALITY` |
| Connection state | `'connection-state-changed'` | `TRTC.EVENT.CONNECTION_STATE_CHANGED` |
| Error | `'error'` | `TRTC.EVENT.ERROR` |
| Audio volume | `'audio-volume'` | `TRTC.EVENT.AUDIO_VOLUME` |
| Player state | `'player-state-changed'` | `TRTC.EVENT.AUDIO_PLAY_STATE_CHANGED` / `TRTC.EVENT.VIDEO_PLAY_STATE_CHANGED` |

## v5 New Events (No v4 Equivalent)

| v5 Event | Description |
|----------|-------------|
| `TRTC.EVENT.STATISTICS` | Audio/video statistics, fires every 2 seconds |
| `TRTC.EVENT.AUTOPLAY_FAILED` | Browser autoplay blocked |
| `TRTC.EVENT.SCREEN_SHARE_STOPPED` | Screen share stopped (e.g., user clicked browser's "Stop sharing") |
| `TRTC.EVENT.DEVICE_CHANGED` | Device plugged/unplugged |
| `TRTC.EVENT.PUBLISH_STATE_CHANGED` | Publish state changed |
| `TRTC.EVENT.TRACK` | Get underlying MediaStreamTrack |
| `TRTC.EVENT.SEI_MESSAGE` | Received SEI message |
| `TRTC.EVENT.CUSTOM_MESSAGE` | Received custom message |
| `TRTC.EVENT.FIRST_VIDEO_FRAME` | First video frame rendered |
| `TRTC.EVENT.PERMISSION_STATE_CHANGE` | Device permission state changed |
| `TRTC.EVENT.VIDEO_SIZE_CHANGED` | Video size changed |
| `TRTC.EVENT.AUDIO_FRAME` | Audio frame data |

## v5 New Capabilities

### Plugin System

```javascript
import { PluginName } from 'trtc-sdk-v5/plugins/plugin-name';
const trtc = TRTC.create({ plugins: [new PluginName()] });
await trtc.startPlugin('PluginName', options);
await trtc.updatePlugin('PluginName', newOptions);
await trtc.stopPlugin('PluginName');
```

Available plugins: Beauty, BasicBeauty, VirtualBackground, AIDenoiser, AudioMixer, Watermark, CDNStreaming, CrossRoom, DeviceDetector, VideoMixer, VoiceChanger, FaceDetection, RealtimeTranscriber, Chorus, Debug, etc.

### switchRoom

```javascript
await trtc.switchRoom({ roomId: newRoomId });
```

### sendCustomMessage

```javascript
await trtc.sendCustomMessage({ cmdId: 1, data: new Uint8Array([1, 2, 3]) });
trtc.on(TRTC.EVENT.CUSTOM_MESSAGE, ({ userId, cmdId, data }) => { });
```

## Critical Behavioral Differences

1. **Environment detection API renamed**: `TRTC.checkSystemRequirements()` → `TRTC.isSupported()`. The return result structure is the same (`{ result, detail }`), but v5's `detail` adds `isWebCodecsSupported`, `isScreenShareSupported`, `isSmallStreamSupported` fields.
2. **autoReceiveVideo**: Since v5.6.0, defaults to `false`. Must listen to `REMOTE_VIDEO_AVAILABLE` and call `startRemoteVideo()` manually.
3. **autoReceiveAudio**: Defaults to `true`. Remote audio auto-subscribes and plays. Set `autoReceiveAudio: false` in `enterRoom` to control manually.
4. **Statistics**: No `getStatistics()` method. All stats via `TRTC.EVENT.STATISTICS` event (fires every 2s).
5. **roomId types**: v5 supports both numeric `roomId` (range: 1~4294967294) and string `strRoomId`.
6. **Autoplay handling**: v5 provides `AUTOPLAY_FAILED` event and `enableAutoPlayDialog` option in `enterRoom`.
7. **screen share**: v5 uses `startScreenShare()`/`stopScreenShare()`, no need to create a separate stream.
8. **`mode` → `scene`**: The `mode` parameter in v4's `createClient()` maps to `scene` in v5's `enterRoom()`.
9. **Role constants**: `'anchor'`/`'audience'` strings → `TRTC.TYPE.ROLE_ANCHOR`/`TRTC.TYPE.ROLE_AUDIENCE` constants.
10. **Audio volume event**: The `audioVolume` field in v4's event callback is renamed to `volume` in v5.

## Common Migration Omissions Checklist

> ⚠️ These are the most frequently missed items during migration. Always verify each item when migrating code.

### 1. Publish Omission
**v4**: `client.publish(stream)` publishes both video + audio when the stream has both tracks
**v5**: Must call `trtc.startLocalVideo()` + `trtc.startLocalAudio()` separately

**How to confirm v4 publishes both video + audio:**
- Search for `TRTC.createStream({ audio: true, video: true })` — dual-track streams published via single `publish()`
- Search for `client.publish(localStream)` where localStream has `audio: true, video: true`
- If v4 code has two separate `publish()` calls (one for audio stream, one for video stream), v5 migration should also split into two calls

```javascript
// ❌ Wrong: only migrated audio, video is missing
await trtc.startLocalAudio();

// ✅ Correct: video + audio must both be called
await trtc.startLocalVideo({ view: 'local' });
await trtc.startLocalAudio();
```

### 2. Unpublish Omission
**v5**: `stopLocalVideo()` + `stopLocalAudio()` must match the corresponding start calls

### 3. isSupported Return Value Confusion
**Wrong**: `result.isSupported`
**Correct**: `checkResult.result` (v5 has the same return structure as v4: `{ result, detail }`)

```javascript
// ❌ Wrong
TRTC.isSupported().then((result) => {
  if (!result.isSupported) { ... }
});

// ✅ Correct
TRTC.isSupported().then((checkResult) => {
  if (!checkResult.result) { ... }
});
```

### 4. Remote Stream Subscription Omission
**v5 (audio)**: `autoReceiveAudio` defaults to `true`, no manual subscription needed

```javascript
// ✅ Must add remote video listener
trtc.on(TRTC.EVENT.REMOTE_VIDEO_AVAILABLE, ({ userId, streamType }) => {
  trtc.startRemoteVideo({ userId, streamType, view: `remote-${userId}` });
});
```

### 5. Remote Stream DOM Readiness (Framework-Agnostic)
In v4, `stream-subscribed` fires after the stream is ready **and the view element exists**. In v5, `REMOTE_VIDEO_AVAILABLE` is only a signal — the view element may not exist yet if your app dynamically renders remote stream containers.

**Two issues to check:**
1. **View element creation**: Does `REMOTE_USER_ENTER` (or `REMOTE_VIDEO_AVAILABLE`) create the view container element before `startRemoteVideo()` is called?
2. **DOM readiness**: Is `startRemoteVideo()` called **after** the view element is inserted into the DOM? Use framework-specific microtask/queue flush if the element is rendered asynchronously.

```javascript
// ❌ Wrong: view element may not exist yet
function handleRemoteVideoAvailable({ userId, streamType }) {
  trtc.startRemoteVideo({ userId, streamType, view: `remote-${userId}` });
}

// ✅ Correct: ensure view exists in DOM before calling startRemoteVideo
// React: use useEffect with empty deps, or flushSync
// Vue: use nextTick()
// Vanilla JS / others: ensure your render pipeline completes first
function handleRemoteVideoAvailable({ userId, streamType }) {
  // 1. Create the view container if not exists
  if (!document.getElementById(`remote-${userId}`)) {
    createViewElement(userId); // your framework's way to render the container
  }
  // 2. Wait for DOM update, then start remote video
  await waitForDOMUpdate(); // framework-specific: nextTick / flushSync / etc.
  trtc.startRemoteVideo({ userId, streamType, view: `remote-${userId}` });
}
```

## Common Migration Patterns

### Pattern 1: Basic Video Call

**v4:**
```javascript
import TRTC from 'trtc-js-sdk';
const client = TRTC.createClient({ sdkAppId, userId, userSig, mode: 'rtc' });
client.on('stream-added', (e) => client.subscribe(e.stream));
client.on('stream-subscribed', (e) => e.stream.play('remote'));
client.on('stream-removed', (e) => e.stream.stop());
await client.join({ roomId });
const localStream = TRTC.createStream({ userId, audio: true, video: true });
await localStream.initialize();
localStream.play('local');
await client.publish(localStream);
```

**v5:**
```javascript
import TRTC from 'trtc-sdk-v5';
const trtc = TRTC.create();

// 1. Ensure view container exists before calling startRemoteVideo
// (Your framework should create the DOM element for remote-${userId})
trtc.on(TRTC.EVENT.REMOTE_USER_ENTER, ({ userId }) => {
  // Create view container: document.createElement('div') + appendChild
  // Or update your framework's state (React setState / Vue store / etc.)
  addRemoteUser(userId); // your implementation
});

trtc.on(TRTC.EVENT.REMOTE_USER_EXIT, ({ userId }) => {
  removeRemoteUser(userId); // your implementation
});

// 2. Wait for DOM to be ready, then start remote video
// Use: nextTick() in Vue, setTimeout(fn, 0) in React, requestAnimationFrame, etc.
trtc.on(TRTC.EVENT.REMOTE_VIDEO_AVAILABLE, async ({ userId, streamType }) => {
  await waitForDOMReady(); // your framework's DOM flush mechanism
  trtc.startRemoteVideo({ userId, streamType, view: `remote-${userId}` });
});

trtc.on(TRTC.EVENT.REMOTE_VIDEO_UNAVAILABLE, ({ userId, streamType }) => {
  trtc.stopRemoteVideo({ userId, streamType });
});

await trtc.enterRoom({ sdkAppId, userId, userSig, roomId, scene: 'rtc' });
await trtc.startLocalVideo({ view: 'local' });
await trtc.startLocalAudio();
```

### Pattern 2: Screen Share

**v4 (v4.15+):**
```javascript
const shareStream = TRTC.createStream({ userId, audio: false, screen: true });
await shareStream.initialize();
await client.publish(shareStream, { isAuxiliary: true });
// stop
await client.unpublish(shareStream);
shareStream.close();
```

**v5:**
```javascript
await trtc.startScreenShare();
trtc.on(TRTC.EVENT.SCREEN_SHARE_STOPPED, () => { /* handle stop */ });
// stop
await trtc.stopScreenShare();
```

### Pattern 3: Statistics

**v4:**
```javascript
setInterval(async () => {
  const transport = await client.getTransportStats();
  const localAudio = await client.getLocalAudioStats();
  const localVideo = await client.getLocalVideoStats();
  const remoteAudio = await client.getRemoteAudioStats();
  const remoteVideo = await client.getRemoteVideoStats();
}, 2000);
```

**v5:**
```javascript
trtc.on(TRTC.EVENT.STATISTICS, (event) => {
  const { rtt, upLoss, downLoss, localStatistics, remoteStatistics } = event;
});
```

### Pattern 4: Cleanup

**v4:**
```javascript
await client.unpublish(localStream);
localStream.close();
await client.leave();
client.destroy();
```

**v5:**
```javascript
await trtc.stopLocalVideo();
await trtc.stopLocalAudio();
await trtc.exitRoom();
trtc.destroy();
```
