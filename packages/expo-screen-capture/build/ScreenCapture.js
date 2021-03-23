import { useEffect } from 'react';
import ExpoScreenCapture from './ExpoScreenCapture';
const activeTags = new Set();
/**
 * Prevents screenshots and screen recordings. If you are
 * already preventing screen capture, this method does nothing.
 *
 * On iOS, this will only prevent screen recordings, and is only
 * available on iOS 11 and newer. On older iOS versions, this method
 * does nothing.
 *
 * @param key Optional. This will prevent multiple instances of the
 * preventScreenCaptureAsync and allowScreenCaptureAsync methods
 * from conflicting with each other. If provided, you will need to call
 * allowScreenCaptureAsync with the same key in order to re-enable
 * screen capturing. Defaults to 'default'.
 *
 * @example
 * ```typescript
 * preventScreenCaptureAsync();
 * ```
 */
export async function preventScreenCaptureAsync(key = 'default') {
    if (!activeTags.has(key)) {
        activeTags.add(key);
        await ExpoScreenCapture.preventScreenCapture();
    }
}
/**
 * Reallows screenshots and recordings. If you haven't called
 * `preventScreenCapture()` yet, this method does nothing.
 *
 * @param key Optional. This will prevent multiple instances of the
 * preventScreenCaptureAsync and allowScreenCaptureAsync methods
 * from conflicting with each other. If provided, must be the same as the key
 * passed to preventScreenCaptureAsync in order to re-enable
 * screen capturing. Defaults to 'default'.
 *
 * @example
 * ```typescript
 * allowScreenCaptureAsync();
 * ```
 */
export async function allowScreenCaptureAsync(key = 'default') {
    activeTags.delete(key);
    if (activeTags.size === 0) {
        await ExpoScreenCapture.allowScreenCapture();
    }
}
/**
 * React hook for preventing screenshots and screen recordings
 * while the component is mounted.
 *
 * @param key Optional. If provided, this will prevent multiple instances of
 * this hook or the preventScreenCaptureAsync and allowScreenCaptureAsync
 * methods from conflicting with each other. Defaults to 'default'.
 *
 * @example
 * ```typescript
 * usePreventScreenCapture();
 * ```
 */
export function usePreventScreenCapture(key = 'default') {
    useEffect(() => {
        preventScreenCaptureAsync(key);
        return () => {
            allowScreenCaptureAsync(key);
        };
    }, [key]);
}
//# sourceMappingURL=ScreenCapture.js.map