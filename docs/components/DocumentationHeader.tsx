import { css } from '@emotion/core';
import Link from 'next/link';
import * as React from 'react';

import AlgoliaSearch from '~/components/plugins/AlgoliaSearch';
import { isEasReleased } from '~/constants/FeatureFlags';
import * as Constants from '~/constants/theme';

const STYLES_LOGO = css`
  display: flex;
`;

const STYLES_UNSTYLED_ANCHOR = css`
  color: inherit;
  text-decoration: none;
`;

const STYLES_TITLE_TEXT = css`
  color: inherit;
  text-decoration: none;
  white-space: nowrap;
  padding-left: 8px;
  font-size: 1.2rem;
  font-family: ${Constants.fonts.bold};
`;

const STYLES_LEFT = css`
  flex-shrink: 0;
  padding-right: 24px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
`;

const STYLES_RIGHT = css`
  min-width: 5%;
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
`;

const STYLES_LOGO_CONTAINER = css`
  display: flex;
  flex-direction: row;
  align-items: center;
`;

const STYLES_NAV = css`
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
  background-color: ${Constants.expoColors.white};
  z-index: 2;
  margin: 0 auto;
  padding: 0 16px;
  height: 60px;
  box-sizing: unset;
  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    border-bottom: 1px solid ${Constants.expoColors.semantic.border};
  }
`;

const STYLES_MOBILE_NAV = css`
  padding: 0px;
  height: 56px;
  background: ${Constants.expoColors.white};
  display: none;

  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    display: flex;
    border-bottom: 1px solid ${Constants.expoColors.semantic.border};
  }
`;

const STYLES_STICKY = css`
  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    position: sticky;
    top: 0px;
    z-index: 3;
  }
`;

const STYLES_SEARCH_OVERLAY = css`
  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    z-index: 1;
    position: fixed;
    top: 0px;
    left: 0px;
    right: 0px;
    bottom: 0px;
    opacity: 0.5;
    background-color: ${Constants.expoColors.black};
  }
`;

const STYLES_HIDDEN_ON_MOBILE = css`
  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    display: none;
  }
`;

const SECTION_LINKS_WRAPPER = css`
  margin-left: 16px;

  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    margin-left: 0px;
  }
`;

const STYLES_MENU_BUTTON_CONTAINER = css`
  display: grid;
  grid-gap: 12px;
  grid-auto-flow: column;
`;

const STYLES_MENU_BUTTON = css`
  display: none;
  cursor: pointer;
  align-items: center;
  justify-content: center;
  height: 40px;
  width: 40px;
  border-radius: 4px;

  :hover {
    background-color: ${Constants.expoColors.gray[100]};
  }

  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    display: grid;
  }
`;

const SECTION_LINK = css`
  text-decoration: none;
  font-family: ${Constants.fontFamilies.demi};
  cursor: pointer;

  padding: 0 16px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-radius: 4px;

  :hover {
    background-color: ${Constants.expoColors.gray[200]};
  }

  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    height: 56px;
    border-radius: 0px;
  }
`;

const SECTION_LINK_ACTIVE = css`
  background-color: ${Constants.expoColors.gray[200]};
`;

const SECTION_LINK_TEXT = css`
  color: ${Constants.colors.black90} !important;
  bottom: 0;
  left: 0;
  right: 0;
`;

type SectionContainerProps = {
  children: JSX.Element[];
  spaceBetween?: number;
  spaceAround?: number;
  style?: React.CSSProperties;
  className?: string;
};

const SectionContainer: React.FC<SectionContainerProps> = ({
  spaceBetween = 0,
  spaceAround = 0,
  children,
  style,
  className,
}) => {
  return (
    <div
      className={className}
      style={{ display: 'flex', paddingLeft: spaceAround, paddingRight: spaceAround, ...style }}>
      {children.map((child, i) => (
        <div key={i.toString()} style={{ paddingLeft: i === 0 ? 0 : spaceBetween }}>
          {child}
        </div>
      ))}
    </div>
  );
};

type Props = {
  isAlgoliaSearchHidden: boolean;
  isMenuActive: boolean;
  isMobileSearchActive: boolean;
  version: string;
  activeSection?: string;
  onToggleSearch: () => void;
  onShowMenu: () => void;
  onHideMenu: () => void;
};

export default class DocumentationHeader extends React.PureComponent<Props> {
  render() {
    return (
      <div>
        <header css={[STYLES_NAV, STYLES_STICKY]}>
          <div css={STYLES_LEFT}>
            <div css={STYLES_LOGO_CONTAINER}>
              <Link href="/" passHref>
                <a css={STYLES_UNSTYLED_ANCHOR}>
                  <span css={STYLES_LOGO}>
                    <img src="/static/images/header/sdk.svg" />
                  </span>
                </a>
              </Link>

              <Link href="/" passHref>
                <a css={STYLES_UNSTYLED_ANCHOR}>
                  <h1 css={STYLES_TITLE_TEXT}>Expo</h1>
                </a>
              </Link>

              {this.renderSectionLinks(true)}
            </div>
          </div>
          <div css={STYLES_RIGHT}>
            {!this.props.isAlgoliaSearchHidden && (
              <AlgoliaSearch version={this.props.version} hiddenOnMobile />
            )}

            {!this.props.isMenuActive && (
              <div css={STYLES_MENU_BUTTON_CONTAINER}>
                <span css={STYLES_MENU_BUTTON} onClick={this.props.onToggleSearch}>
                  <img src="/static/images/header/search.svg" />
                </span>
                <span css={STYLES_MENU_BUTTON} onClick={this.props.onShowMenu}>
                  <img src="/static/images/header/more-horizontal.svg" />
                </span>
              </div>
            )}

            {this.props.isMenuActive && (
              <span css={STYLES_MENU_BUTTON} onClick={this.props.onHideMenu}>
                <img src="/static/images/header/x.svg" />
              </span>
            )}
          </div>
        </header>
        <header css={[STYLES_NAV, STYLES_MOBILE_NAV]}>
          {this.props.isMobileSearchActive ? (
            <AlgoliaSearch
              version={this.props.version}
              hiddenOnMobile={false}
              onToggleSearch={this.props.onToggleSearch}
            />
          ) : (
            this.renderSectionLinks(false)
          )}
        </header>
        <div css={this.props.isMobileSearchActive && STYLES_SEARCH_OVERLAY} />
      </div>
    );
  }

  private renderSectionLinks = (hiddenOnMobile: boolean) => {
    return (
      <div css={[SECTION_LINKS_WRAPPER, hiddenOnMobile && STYLES_HIDDEN_ON_MOBILE]}>
        <SectionContainer spaceBetween={hiddenOnMobile ? 8 : 0}>
          <Link href="/" passHref>
            <a css={[SECTION_LINK, this.props.activeSection === 'starting' && SECTION_LINK_ACTIVE]}>
              <span css={SECTION_LINK_TEXT}>Get Started</span>
            </a>
          </Link>
          <Link href="/guides" passHref>
            <a css={[SECTION_LINK, this.props.activeSection === 'general' && SECTION_LINK_ACTIVE]}>
              <span css={SECTION_LINK_TEXT}>Guides</span>
            </a>
          </Link>
          {isEasReleased ? (
            <Link href="/eas" passHref>
              <a css={[SECTION_LINK, this.props.activeSection === 'eas' && SECTION_LINK_ACTIVE]}>
                <span css={SECTION_LINK_TEXT}>Feature Preview</span>
              </a>
            </Link>
          ) : (
            <span />
          )}
          <Link href="/versions/latest/" passHref>
            <a
              css={[SECTION_LINK, this.props.activeSection === 'reference' && SECTION_LINK_ACTIVE]}>
              <span css={SECTION_LINK_TEXT}>API Reference</span>
            </a>
          </Link>
        </SectionContainer>
      </div>
    );
  };
}
