---
name: v4-to-v5-migration
description: "Migrates TRTC Web SDK code from v4 (trtc-js-sdk) to v5 (trtc-sdk-v5). Use when users request v4→v5 upgrade, mention 'trtc-js-sdk migration', 'upgrade to v5', 'v4 to v5', or when their code contains v4 patterns like TRTC.createClient(), TRTC.createStream(), TRTC.checkSystemRequirements(), client.join(), stream.initialize(), stream.play()."
---

# TRTC Web SDK v4 → v5 Migration Skill

## Overview

This skill automates the migration of TRTC Web SDK code from **v4 (`trtc-js-sdk`)** to **v5 (`trtc-sdk-v5`)**. It analyzes the user's existing v4 codebase, identifies all v4 API patterns, and performs a systematic, safe migration following the official migration guide.

### Architecture Change Summary

- **v4**: `Client + Stream` separated model — `TRTC.createClient()` for signaling, `TRTC.createStream()` for media.
- **v5**: Unified `TRTC` instance — `TRTC.create()` single instance handles everything.

## Workflow

**CRITICAL: Follow these steps IN ORDER. Do NOT skip steps.**

### Step 1: Scan — Discover v4 Code

Search the user's codebase to find all files containing v4 SDK patterns.

**Search for these v4 markers** (use `search_content` or `codebase_search`):

```
TRTC.createClient
TRTC.createStream
trtc-js-sdk
client.join
client.leave
client.publish
client.unpublish
client.subscribe
client.unsubscribe
stream.initialize
stream.play
stream.stop
stream.close
stream.muteAudio
stream.unmuteAudio
stream.muteVideo
stream.unmuteVideo
stream.switchDevice
stream.setVideoProfile
stream.setAudioProfile
client.switchRole
client.enableAudioVolumeEvaluation
client.enableSmallStream
client.setSmallStreamProfile
client.setRemoteVideoStreamType
client.getTransportStats
client.getLocalAudioStats
client.getLocalVideoStats
client.getRemoteAudioStats
client.getRemoteVideoStats
client.sendSEIMessage
client.on('stream-added
client.on('stream-subscribed
client.on('stream-removed
client.on('stream-updated
client.on('peer-join
client.on('peer-leave
client.on('mute-audio
client.on('unmute-audio
client.on('mute-video
client.on('unmute-video
client.on('client-banned
client.on('network-quality
client.on('connection-state-changed
client.on('error
client.on('audio-volume
client.on('player-state-changed
TRTC.getDevices
TRTC.getCameras
TRTC.getMicrophones
TRTC.getSpeakers
```

**Output a summary** listing:
- All files containing v4 code
- For each file: which v4 APIs/events are used
- The overall scope of migration (number of files, complexity estimate)

### Step 2: Analyze — Build Migration Plan

Read the reference file at `{SKILL_DIR}/references/migration-guide.md` for the complete API and event mapping tables.

For each file found in Step 1, create a migration plan:

1. **Package change**: `trtc-js-sdk` → `trtc-sdk-v5`
2. **Instance creation**: `TRTC.createClient()` + `TRTC.createStream()` → `TRTC.create()`
4. **Room operations**: `client.join()` → `trtc.enterRoom()`, `client.leave()` → `trtc.exitRoom()`
5. **Local media**: `stream.initialize()` + `stream.play()` + `client.publish()` → `trtc.startLocalVideo()` / `trtc.startLocalAudio()`
6. **Remote media**: `client.on('stream-added')` + `subscribe` + `stream.play()` → `trtc.on(TRTC.EVENT.REMOTE_VIDEO_AVAILABLE)` + `startRemoteVideo()`
7. **Screen sharing**: `createStream({screen:true})` + `client.publish(shareStream, {isAuxiliary:true})` → `trtc.startScreenShare()`
8. **Events**: Map all v4 events to v5 events (see reference)
9. **Device APIs**: `TRTC.getCameras()` → `TRTC.getCameraList()`, etc.
10. **Statistics**: `client.getXxxStats()` polling → `TRTC.EVENT.STATISTICS` event
11. **Other**: Small stream, SEI messages, volume detection, role switching, etc.

### Step 3: Confirm — Present Plan to User

Present the migration plan to the user with:
- List of files to modify
- Summary of changes per file
- Any **breaking changes** or **behavioral differences** to be aware of:
  - `autoReceiveVideo` defaults to `false` since v5.6.0
  - Audio is auto-subscribed by default in v5
  - Statistics are event-driven, not polling-based
  - `mode` param renamed to `scene`
  - Auth params (`sdkAppId`, `userId`, `userSig`) moved from constructor to `enterRoom`

**Wait for user confirmation before proceeding to Step 4.**

### Step 4: Migrate — Apply Changes

Apply changes file by file using `replace_in_file`. For each file:

#### 4.1 Update Import

```javascript
// v4 (FIND)
import TRTC from 'trtc-js-sdk';

// v5 (REPLACE)
import TRTC from 'trtc-sdk-v5';
```

#### 4.2 Replace Environment Detection

```javascript
// v4 (FIND)
TRTC.checkSystemRequirements().then((checkResult) => {
  if (!checkResult.result) {
    // ...
  }
});

// v5 (REPLACE)
TRTC.isSupported().then((checkResult) => {
  if (!checkResult.result) {
    // ...
  }
});
```

> **Note:** The return result structure is the same — both return `{ result: boolean, detail: { isBrowserSupported, isWebRTCSupported, ... } }`. v5's `detail` adds `isWebCodecsSupported`, `isScreenShareSupported`, `isSmallStreamSupported` fields.

#### 4.3 Replace Instance Creation

```javascript
// v4 (FIND patterns like)
const client = TRTC.createClient({ sdkAppId, userId, userSig, mode: 'rtc' });
const localStream = TRTC.createStream({ userId, audio: true, video: true });

// v5 (REPLACE with)
const trtc = TRTC.create();
```

> **Note:** Save the `sdkAppId`, `userId`, `userSig`, and `mode` values — they will be needed in `enterRoom`.

#### 4.4 Replace Room Operations

```javascript
// v4
await client.join({ roomId: 1234 });
await client.leave();

// v5 — note: sdkAppId/userId/userSig/scene move here
await trtc.enterRoom({ sdkAppId, userId, userSig, roomId: 1234, scene: 'rtc' });
await trtc.exitRoom();
```

#### 4.5 Replace Local Media

```javascript
// v4 (FIND the pattern of initialize → play → publish)
await localStream.initialize();
localStream.play('local-video-container');
await client.publish(localStream);

// v5 (REPLACE with)
await trtc.startLocalVideo({ view: 'local-video-container' });
await trtc.startLocalAudio();
```

```javascript
// v4 cleanup
client.unpublish(localStream);
localStream.close();

// v5 cleanup
await trtc.stopLocalVideo();
await trtc.stopLocalAudio();
```

#### 4.6 Replace Remote Stream Handling

```javascript
// v4 (FIND the stream-added → subscribe → stream-subscribed → play pattern)
client.on('stream-added', (event) => {
  client.subscribe(event.stream);
});
client.on('stream-subscribed', (event) => {
  event.stream.play('remote-container');
});
client.on('stream-removed', (event) => {
  event.stream.stop();
});

// v5 (REPLACE with)
trtc.on(TRTC.EVENT.REMOTE_VIDEO_AVAILABLE, ({ userId, streamType }) => {
  trtc.startRemoteVideo({ userId, streamType, view: `remote-video-${userId}` });
});
trtc.on(TRTC.EVENT.REMOTE_VIDEO_UNAVAILABLE, ({ userId, streamType }) => {
  // Video playback automatically stopped
});
```

#### 4.7 Replace Event Listeners

Use the event mapping from the reference file. Key mappings:

| v4 Event | v5 Event |
|----------|----------|
| `'stream-added'` | `TRTC.EVENT.REMOTE_VIDEO_AVAILABLE` / `TRTC.EVENT.REMOTE_AUDIO_AVAILABLE` |
| `'stream-subscribed'` | _(removed — handled internally by startRemoteVideo)_ |
| `'stream-removed'` | `TRTC.EVENT.REMOTE_VIDEO_UNAVAILABLE` / `TRTC.EVENT.REMOTE_AUDIO_UNAVAILABLE` |
| `'peer-join'` | `TRTC.EVENT.REMOTE_USER_ENTER` |
| `'peer-leave'` | `TRTC.EVENT.REMOTE_USER_EXIT` |
| `'mute-audio'` | `TRTC.EVENT.REMOTE_AUDIO_UNAVAILABLE` |
| `'unmute-audio'` | `TRTC.EVENT.REMOTE_AUDIO_AVAILABLE` |
| `'mute-video'` | `TRTC.EVENT.REMOTE_VIDEO_UNAVAILABLE` |
| `'unmute-video'` | `TRTC.EVENT.REMOTE_VIDEO_AVAILABLE` |
| `'client-banned'` | `TRTC.EVENT.KICKED_OUT` |
| `'network-quality'` | `TRTC.EVENT.NETWORK_QUALITY` |
| `'connection-state-changed'` | `TRTC.EVENT.CONNECTION_STATE_CHANGED` |
| `'error'` | `TRTC.EVENT.ERROR` |
| `'audio-volume'` | `TRTC.EVENT.AUDIO_VOLUME` |
| `'player-state-changed'` | `TRTC.EVENT.AUDIO_PLAY_STATE_CHANGED` / `TRTC.EVENT.VIDEO_PLAY_STATE_CHANGED` |

#### 4.8 Replace Screen Sharing

```javascript
// v4
const shareStream = TRTC.createStream({ userId, audio: false, screen: true });
await shareStream.initialize();
await client.publish(shareStream, { isAuxiliary: true });

// v5
await trtc.startScreenShare();
```

#### 4.9 Replace Device APIs

```javascript
// v4
TRTC.getDevices()     → // removed, use individual list APIs
TRTC.getCameras()     → TRTC.getCameraList()
TRTC.getMicrophones() → TRTC.getMicrophoneList()
TRTC.getSpeakers()    → TRTC.getSpeakerList()

// v4 device switch
localStream.switchDevice('video', cameraId) → trtc.updateLocalVideo({ option: { cameraId } })
localStream.switchDevice('audio', micId)    → trtc.updateLocalAudio({ option: { microphoneId: micId } })
```

#### 4.10 Replace Statistics

```javascript
// v4 (FIND polling pattern)
const transportStats = await client.getTransportStats();
const localAudioStats = await client.getLocalAudioStats();
// ...

// v5 (REPLACE with event listener)
trtc.on(TRTC.EVENT.STATISTICS, (event) => {
  const { rtt, upLoss, downLoss, localStatistics, remoteStatistics } = event;
  // Process statistics...
});
```

#### 4.11 Replace Other APIs

```javascript
// Mute/unmute
stream.muteAudio()   → trtc.updateLocalAudio({ mute: true })
stream.unmuteAudio() → trtc.updateLocalAudio({ mute: false })
stream.muteVideo()   → trtc.updateLocalVideo({ mute: true })
stream.unmuteVideo() → trtc.updateLocalVideo({ mute: false })

// Video/Audio profile
stream.setVideoProfile('480p') → trtc.updateLocalVideo({ option: { profile: '480p' } })
stream.setAudioProfile('standard') → trtc.updateLocalAudio({ option: { profile: 'standard' } })

// Small stream
client.enableSmallStream() + client.setSmallStreamProfile({...})
  → trtc.updateLocalVideo({ option: { small: { width, height, bitrate, frameRate } } })

client.setRemoteVideoStreamType(remoteStream, 'small')
  → trtc.updateRemoteVideo({ userId, streamType: TRTC.TYPE.STREAM_TYPE_MAIN, option: { small: true } })

// Role switch
client.switchRole('anchor') → trtc.switchRole(TRTC.TYPE.ROLE_ANCHOR)
client.switchRole('audience') → trtc.switchRole(TRTC.TYPE.ROLE_AUDIENCE)

// SEI message
client.sendSEIMessage(buffer) → trtc.sendSEIMessage(buffer)

// Volume evaluation
client.enableAudioVolumeEvaluation(200) → trtc.enableAudioVolumeEvaluation(200)

// Destroy
client.destroy() → trtc.destroy()
```

### Step 5: Update package.json

```javascript
// FIND in package.json dependencies
"trtc-js-sdk": "x.x.x"

// REPLACE with
"trtc-sdk-v5": "latest"
```

### Step 6: Verify — Post-Migration Check

After all changes are applied:

1. **Re-scan** for any remaining v4 patterns (repeat Step 1 search terms)
2. **Check linter errors** using `read_lints` on modified files
3. **Report** to user:
   - Files modified
   - Remaining issues (if any)
   - Behavioral changes to test manually:
     - Remote video requires explicit `startRemoteVideo()` call
     - Remote audio auto-plays by default
     - Statistics now via event listener instead of polling
     - Screen share simplified to single API call

## Important Notes

### Variable Naming Convention
- v4 uses `client` and `localStream` / `remoteStream` as variable names
- v5 uses `trtc` as the unified variable name
- When migrating, rename `client` → `trtc` throughout the affected scope
- Remove all `localStream` / `remoteStream` / `shareStream` variables as they are no longer needed

### Handling Complex Patterns
- If v4 code uses **multiple clients** (e.g., separate client for screen sharing in pre-v4.15), consolidate into a single `trtc` instance in v5
- If v4 code manages **stream lifecycle manually** (create → initialize → play → publish → unpublish → close), replace with the simplified v5 API calls
- If v4 code uses **custom audio/video sources** via `createStream({ audioSource, videoSource })`, migrate to `trtc.startLocalVideo({ option: { videoTrack } })` / `trtc.startLocalAudio({ option: { audioTrack } })`

### Plugin Migration
If v4 code uses features that are now plugins in v5 (beauty, AI denoiser, watermark, etc.), guide the user on the new plugin system:

```javascript
import { Beauty } from 'trtc-sdk-v5/plugins/beauty';
const trtc = TRTC.create({ plugins: [new Beauty()] });
await trtc.startPlugin('Beauty', { beauty: 0.5 });
```

## Resources

### references/
Contains `migration-guide.md` — the complete API mapping table, event mapping table, and migration reference extracted from the official TRTC documentation. **Always read this file** during Step 2 for the authoritative mapping data.
