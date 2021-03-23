import Router from 'next/router';
import * as React from 'react';
import { css } from 'react-emotion';

import * as Constants from '~/common/constants';
import * as Utilities from '~/common/utilities';
import { LATEST_VERSION, VERSIONS } from '~/common/versions';

const STYLES_INPUT = css`
  display: flex;
  position: relative;
  align-items: flex-end;

  .searchbox {
    width: auto;
  }

  .searchbox__submit {
    pointer-events: none;
  }

  .searchbox__input,
  input {
    font-family: ${Constants.fontFamilies.book};
    color: ${Constants.colors.black80};
    box-sizing: border-box;
    width: 380px;
    font-size: 14px;
    padding: 2px 36px 0 14px;
    border-radius: 5px;
    height: 36px;
    outline: 0;
    border: 1px solid ${Constants.colors.border};
    box-shadow: 0px 0px 3px rgba(0, 0, 0, 0.08);

    :hover {
      border-color: rgba(0, 0, 0, 0.4);
      box-shadow: 0px 0px 2px rgba(0, 0, 0, 0.4);
    }

    :focus {
      border: 1px solid ${Constants.colors.expo};
      outline: 0;
    }
  }

  .svg-icons {
    left: 240px;
  }

  @media screen and (max-width: ${Constants.breakpoints.mobile}) {
    display: none;
  }

  .shortcut-hint {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    height: 20px;
    width: 20px;
    border: 1px solid rgba(0, 0, 0, 0.2);
    color: rgba(0, 0, 0, 0.3);
    border-radius: 5px;
    right: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding-top: 2px;
    pointer-events: none;
  }
`;

// TODO(jim): Not particularly happy with how this component chunks in while loading.
class AlgoliaSearch extends React.Component {
  state = {
    isFocused: false,
  };

  processUrl(url) {
    // Update URLs for new doc URLs
    var routes = url.split('/');
    routes[routes.length - 1] = routes[routes.length - 1].replace('.html', '');
    return routes.join('/');
  }

  componentDidMount() {
    const docsearch = require('docsearch.js');
    const Hotshot = require('hotshot');

    // we need to explicitly ignore the non-selected versions in algolia to
    // include the "guides" and "get started" pages next to the API docs.
    // algolia doesn't allow us to filter on `version:v37.0.0 OR version:<null>`
    const currentVersion = this.props.version === 'latest' ? LATEST_VERSION : this.props.version;
    const ignoredVersionList = VERSIONS.filter(version => currentVersion !== version).map(
      version => `version:-${version}`
    );

    this.docsearch = docsearch({
      apiKey: '2955d7b41a0accbe5b6aa2db32f3b8ac',
      indexName: 'expo',
      inputSelector: '#algolia-search-box',
      enhancedSearchInput: false,
      transformData: hits => {
        // modify hits to account for no anchors on page headings
        hits.map(hit => {
          hit.url = hit.url.replace(/#__next$/, '');
          hit.anchor = hit.anchor.replace(/^__next$/, '');
        });

        return hits;
      },
      algoliaOptions: {
        facetFilters: ignoredVersionList,
      },
      handleSelected: (input, event, suggestion) => {
        input.setVal('');

        const url = new URL(suggestion.url);
        const route = this.processUrl(url.pathname + url.hash);

        let asPath;
        if (Utilities.isVersionedUrl(suggestion.url) && this.props.version === 'latest') {
          asPath = this.processUrl(Utilities.replaceVersionInUrl(route, 'latest'));
        }

        if (asPath) {
          Router.push(route, asPath);
        } else {
          Router.push(route);
        }

        const docSearchEl = document.getElementById('docsearch');
        if (docSearchEl) {
          docSearchEl.blur();
        }

        const searchbox = document.querySelector('input#docsearch');
        const reset = document.querySelector('.searchbox [type="reset"]');

        if (reset) {
          reset.className = 'searchbox__reset';
          if (searchbox && searchbox.value.length === 0) {
            reset.className += ' hide';
          }
        }

        this.props.closeSidebar && this.props.closeSidebar();
      },
    });

    // add keyboard shortcut
    this.hotshot = new Hotshot({
      combos: [
        {
          keyCodes: [191], // open search by pressing / key
          callback: () =>
            setTimeout(() => document.getElementById('algolia-search-box').focus(), 16),
        },
      ],
    });
  }

  render() {
    return (
      <div className={STYLES_INPUT} style={this.props.style}>
        <input
          onFocus={() => this.setState({ isFocused: true })}
          onBlur={() => this.setState({ isFocused: false })}
          id="algolia-search-box"
          type="text"
          placeholder="Search Expo Documentation"
          autoComplete="off"
          spellCheck="false"
          dir="auto"
        />

        <div className="shortcut-hint" style={{ display: this.state.isFocused ? 'none' : 'flex' }}>
          /
        </div>
      </div>
    );
  }
}

export default AlgoliaSearch;
