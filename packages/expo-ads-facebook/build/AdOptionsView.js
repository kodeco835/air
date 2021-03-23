import { requireNativeViewManager } from '@unimodules/core';
import nullthrows from 'nullthrows';
import React from 'react';
import { findNodeHandle } from 'react-native';
import { AdOptionsViewContext } from './withNativeAd';
var NativeOrientation;
(function (NativeOrientation) {
    NativeOrientation[NativeOrientation["Horizontal"] = 0] = "Horizontal";
    NativeOrientation[NativeOrientation["Vertical"] = 1] = "Vertical";
})(NativeOrientation || (NativeOrientation = {}));
let AdOptionsView = /** @class */ (() => {
    class AdOptionsView extends React.Component {
        constructor() {
            super(...arguments);
            this.shouldAlignHorizontal = () => this.props.orientation === 'horizontal';
        }
        render() {
            const style = this.shouldAlignHorizontal()
                ? {
                    width: this.props.iconSize * 2,
                    height: this.props.iconSize,
                }
                : {
                    width: this.props.iconSize,
                    height: this.props.iconSize * 2,
                };
            return (React.createElement(AdOptionsViewContext.Consumer, null, (contextValue) => {
                const adViewRef = nullthrows(contextValue && contextValue.nativeAdViewRef);
                return (React.createElement(NativeAdOptionsView, Object.assign({}, this.props, { style: [this.props.style, style], nativeAdViewTag: findNodeHandle(adViewRef.current), orientation: this.shouldAlignHorizontal()
                        ? NativeOrientation.Horizontal
                        : NativeOrientation.Vertical })));
            }));
        }
    }
    AdOptionsView.defaultProps = {
        iconSize: 23,
        orientation: 'horizontal',
    };
    return AdOptionsView;
})();
export default AdOptionsView;
export const NativeAdOptionsView = requireNativeViewManager('AdOptionsView');
//# sourceMappingURL=AdOptionsView.js.map