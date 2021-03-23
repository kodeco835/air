import { diff } from 'deep-object-diff';
import { Asset } from 'expo-asset';
import { Video, AVPlaybackStatus, VideoFullscreenUpdateEvent } from 'expo-av';
import React from 'react';
import { StyleProp, ViewStyle } from 'react-native';

import Player from './Player';

interface State {
  sourceIndex: number;
  errorMessage?: string;
  useNativeControls: boolean;
  resizeMode: any;
  status: AVPlaybackStatus;
}

type VideoPlayerSource =
  | number
  | {
      uri: string;
      overrideFileExtensionAndroid?: string;
      headers?: {
        [fieldName: string]: string;
      };
    }
  | Asset;

export default class VideoPlayer extends React.Component<
  {
    style?: StyleProp<ViewStyle>;
    sources: VideoPlayerSource[];
  },
  State
> {
  readonly state: State = {
    sourceIndex: 0,
    useNativeControls: false,
    resizeMode: Video.RESIZE_MODE_CONTAIN,
    status: {
      isLoaded: false,
    },
  };

  _video?: Video;
  private prevStatus?: AVPlaybackStatus;

  _handleError = (errorMessage: string) => this.setState({ errorMessage });

  _handleVideoMount = (ref: Video) => (this._video = ref);

  _handlePlaybackStatusUpdate = (status: AVPlaybackStatus) => {
    console.log('onPlaybackStatusUpdate: ', diff(this.prevStatus || {}, status));
    this.prevStatus = status;
    this.setState({ status });
  };

  _handleFullScreenUpdate = (event: VideoFullscreenUpdateEvent) =>
    console.log('onFullscreenUpdate', event);

  _playAsync = async () => this._video!.playAsync();

  _pauseAsync = async () => this._video!.pauseAsync();

  _replayAsync = async () => this._video!.replayAsync();

  _setPositionAsync = async (position: number) => this._video!.setPositionAsync(position);

  _setIsLoopingAsync = async (isLooping: boolean) => this._video!.setIsLoopingAsync(isLooping);

  _setIsMutedAsync = async (isMuted: boolean) => this._video!.setIsMutedAsync(isMuted);

  _setRateAsync = async (rate: number, shouldCorrectPitch: boolean) =>
    this._video!.setRateAsync(rate, shouldCorrectPitch);

  _toggleNativeControls = () =>
    this.setState(({ useNativeControls }) => ({ useNativeControls: !useNativeControls }));

  _resizeModeSetter = (resizeMode: any) => () => this.setState({ resizeMode });

  _openFullscreen = () => this._video!.presentFullscreenPlayer();

  _changeSource = () => {
    this.setState(state => ({
      sourceIndex: (state.sourceIndex + 1) % this.props.sources.length,
    }));
  };

  _renderVideo = () => (
    <Video
      useNativeControls={this.state.useNativeControls}
      ref={this._handleVideoMount}
      source={this.props.sources[this.state.sourceIndex]}
      resizeMode={this.state.resizeMode}
      onError={this._handleError}
      style={{ height: 300 }}
      progressUpdateIntervalMillis={100}
      onPlaybackStatusUpdate={this._handlePlaybackStatusUpdate}
      onFullscreenUpdate={this._handleFullScreenUpdate}
    />
  );

  render() {
    const { status } = this.state;
    return (
      <Player
        style={this.props.style}
        errorMessage={this.state.errorMessage}
        isLoaded={status.isLoaded}
        isLooping={status.isLoaded ? status.isLooping : false}
        rate={status.isLoaded ? status.rate : 1}
        positionMillis={status.isLoaded ? status.positionMillis : 0}
        durationMillis={status.isLoaded ? status.durationMillis || 0 : 0}
        shouldCorrectPitch={status.isLoaded ? status.shouldCorrectPitch : false}
        isPlaying={status.isLoaded ? status.isPlaying : false}
        isMuted={status.isLoaded ? status.isMuted : false}
        playAsync={this._playAsync}
        pauseAsync={this._pauseAsync}
        replayAsync={this._replayAsync}
        nextAsync={this._changeSource}
        setPositionAsync={this._setPositionAsync}
        setIsLoopingAsync={this._setIsLoopingAsync}
        setIsMutedAsync={this._setIsMutedAsync}
        setRateAsync={this._setRateAsync}
        extraButtons={[
          {
            iconName: 'options',
            title: 'Native controls',
            onPress: this._toggleNativeControls,
            active: this.state.useNativeControls,
          },
          {
            iconName: 'move',
            title: 'Resize mode – stretch',
            onPress: this._resizeModeSetter(Video.RESIZE_MODE_STRETCH),
            active: this.state.resizeMode === Video.RESIZE_MODE_STRETCH,
          },
          {
            iconName: 'log-in',
            title: 'Resize mode – contain',
            onPress: this._resizeModeSetter(Video.RESIZE_MODE_CONTAIN),
            active: this.state.resizeMode === Video.RESIZE_MODE_CONTAIN,
          },
          {
            iconName: 'qr-scanner',
            title: 'Resize mode – cover',
            onPress: this._resizeModeSetter(Video.RESIZE_MODE_COVER),
            active: this.state.resizeMode === Video.RESIZE_MODE_COVER,
          },
          {
            iconName: 'resize',
            title: 'Open full screen',
            onPress: this._openFullscreen,
            active: false,
          },
        ]}
        header={this._renderVideo()}
      />
    );
  }
}
