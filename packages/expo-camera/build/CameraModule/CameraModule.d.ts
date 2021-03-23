import { PictureOptions } from '../Camera.types';
import { CameraType, CapturedPicture, CaptureOptions, ImageType } from './CameraModule.types';
export { ImageType, CameraType, CaptureOptions };
declare type OnCameraReadyListener = () => void;
declare type OnMountErrorListener = ({ nativeEvent: Error }: {
    nativeEvent: any;
}) => void;
declare class CameraModule {
    videoElement: HTMLVideoElement;
    stream: MediaStream | null;
    settings: MediaTrackSettings | null;
    onCameraReady: OnCameraReadyListener;
    onMountError: OnMountErrorListener;
    _pictureSize?: string;
    _isStartingCamera: boolean;
    _autoFocus: string;
    readonly autoFocus: string;
    setAutoFocusAsync(value: string): Promise<void>;
    _flashMode: string;
    readonly flashMode: string;
    setFlashModeAsync(value: string): Promise<void>;
    _whiteBalance: string;
    readonly whiteBalance: string;
    setWhiteBalanceAsync(value: string): Promise<void>;
    _cameraType: CameraType;
    readonly type: CameraType;
    setTypeAsync(value: CameraType): Promise<void>;
    _zoom: number;
    readonly zoom: number;
    setZoomAsync(value: number): Promise<void>;
    setPictureSize(value: string): void;
    constructor(videoElement: HTMLVideoElement);
    onCapabilitiesReady(track: MediaStreamTrack): Promise<void>;
    _syncTrackCapabilities(): Promise<void>;
    setVideoSource(stream: MediaStream | MediaSource | Blob | null): void;
    setSettings(stream: MediaStream | null): void;
    setStream(stream: MediaStream | null): void;
    getActualCameraType(): CameraType | null;
    ensureCameraIsRunningAsync(): Promise<void>;
    resumePreview(): Promise<MediaStream | null>;
    takePicture(config: PictureOptions): CapturedPicture;
    pausePreview(): void;
    getAvailablePictureSizes: (ratio: string) => Promise<string[]>;
    unmount: () => void;
}
export default CameraModule;
