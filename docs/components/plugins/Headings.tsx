import * as React from 'react';

import Permalink from '../Permalink';

import { H1 as RawH1, H2 as RawH2, H3 as RawH3, H4 as RawH4 } from '~/components/base/headings';

type CreateHeading = (Component: React.ElementType, defaultLevel: number) => React.FC;

/**
 * Decorates component with a permalink at specified heading level
 * @param {*} Component component to decorate with
 * @param {number} defaultLevel default heading level for the permalink
 */
const createHeading: CreateHeading = (Component, defaultLevel) => ({ children, ...props }) => {
  return (
    <Permalink nestingLevel={defaultLevel} additionalProps={props}>
      <Component>{children}</Component>
    </Permalink>
  );
};

export const H1 = createHeading(RawH1, 1);
export const H2 = createHeading(RawH2, 2);
export const H3 = createHeading(RawH3, 3);
export const H4 = createHeading(RawH4, 4);