module App.Backends.Jira.Parsers where

import           App.Config
import           App.Types
import           App.Util

import           Control.Lens
import           Control.Monad
import           Data.Either.Combinators
import           Jira.API                hiding (getConfig)
import           Text.Parsec

type StringParser a = Parsec String () a

issueNumberParser :: StringParser IssueNumber
issueNumberParser = IssueNumber . read <$> many1 digit <* eof

issueKeyParser :: StringParser IssueKey
issueKeyParser = do
  project <- many1Till letter (char '-')
  IssueKey project <$> issueNumberParser

issueKeyParserWithDefaultProject :: String -> StringParser IssueKey
issueKeyParserWithDefaultProject project =
  issueKeyParser <|> IssueKey project <$> issueNumberParser

parseIssueKey :: String -> AppM IssueKey
parseIssueKey s = do
  jiraConfig <- takeJiraConfig =<< getConfig
  let project = jiraConfig^.jiraProject
  liftEither $ mapLeft (const parseException) $
               parse (issueKeyParserWithDefaultProject project) "" s
  where
    parseException = UserInputException $
      "Not a valid issue identifier: " ++ s

-- Helpers

many1Till :: Stream s m t => ParsecT s u m a -> ParsecT s u m end -> ParsecT s u m [a]
many1Till p end = do
  r <- manyTill p end
  guard . not $ null r
  return r

