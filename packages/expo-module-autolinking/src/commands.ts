import chalk from 'chalk';
import commander, { Command } from 'commander';
import process from 'process';

import { findModulesAsync, resolveModulesAsync, verifySearchResults } from '.';
import logger, { NonTTYLogger } from './logger';
import { SearchOptions, SearchResults } from './types';

registerSearchingCommand('search', async results => {
  console.log(require('util').inspect(results, false, null, true));
});

registerSearchingCommand('resolve', async (results, command) => {
  const modules = await resolveModulesAsync(command.platform, results);
  console.log(modules);
});

registerSearchingCommand('json', async (results, command) => {
  const modules = await resolveModulesAsync(command.platform, results);
  const logger = new NonTTYLogger();

  logger.log('Using Expo modules');

  verifySearchResults(results, logger);

  console.log(
    JSON.stringify({
      logs: logger.toString(),
      modules,
    })
  );
});

registerSearchingCommand('verify', results => {
  const numberOfDuplicates = verifySearchResults(results);
  if (!numberOfDuplicates) {
    logger.success('✅ Everything is fine!');
  }
});

commander
  .version(require('expo-module-autolinking/package.json').version)
  .description('CLI command that searches for Expo modules to autolink them.')
  .parseAsync(process.argv);

/**
 * Factory for commands that need to search first and shares the same options.
 */
function registerSearchingCommand(
  commandName: string,
  fn: (search: SearchResults, command: Command) => any
) {
  return commander
    .command(`${commandName} [paths...]`)
    .option(
      '-p, --platform [platform]',
      'The platform that the resulting modules must support. Available options: "ios", "android"',
      'ios'
    )
    .option<string[] | null>(
      '-i, --ignore-paths [ignorePaths...]',
      'Paths to ignore when looking up modules.',
      (value, previous) => (previous ?? []).concat(value),
      null
    )
    .option<string[] | null>(
      '-e, --exclude [exclude...]',
      'Package names to exclude when looking up modules.',
      (value, previous) => (previous ?? []).concat(value),
      null
    )
    .action(async (searchPaths, command) => {
      const options: SearchOptions = {
        searchPaths,
        ignorePaths: command.ignorePaths,
        exclude: command.exclude,
      };
      const searchResults = await findModulesAsync(command.platform, options);

      return await fn(searchResults, command);
    });
}
