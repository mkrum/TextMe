{-#LANGUAGE OverloadedStrings #-}

import System.Process
import System.Environment   
import Twilio
import Twilio.Messages
import Twilio.Message
import Control.Concurrent.MVar (newEmptyMVar, takeMVar, putMVar)
import Control.Monad
import System.IO 
import Data.Maybe
import Data.Text (pack, Text)

sendText :: Text -> IO Twilio.Message.Message
sendText message = do
    file <- readFile ".textme.config.numbers"   
    let [b, c] = lines file
        
    let twilio_number = read ("\"" ++ b ++ "\"")
    let user_number = read ("\"" ++ c ++ "\"") 

    runTwilio' (readFile ".textme.config.sid") (getEnv "TEXTME_AUTH") $ post $ PostMessage user_number twilio_number message

getInput :: String -> IO String
getInput prompt = do
    putStr prompt
    hFlush stdout
    getLine

parseArgs :: [String] -> IO Twilio.Message.Message
parseArgs ("--setup":more) = do
    putStrLn "You will need a Twilio Account to use this. Set one up now, if you haven't already"

    account_sid <- getInput "Account SID: "
    auth_token <- getInput "Auth Token: "
    twilio_number <- getInput "Twilio Number (+XXXXXXXXXXX): "
    user_number <- getInput "Your Number (+XXXXXXXXXXX): "
    
    putStrLn "Set the enivorment variable TEXTME_AUTH if you do not want to have to type in this value every time"

    writeFile ".textme.config.sid" account_sid

    writeFile ".textme.config.numbers"  twilio_number
    appendFile ".textme.config.numbers" "\n"
    appendFile ".textme.config.numbers"  user_number

    setEnv "TEXTME_AUTH" auth_token

    sendText "setup complete" 

            
parseArgs args = do
    checkAuth 
    readProcess (head args) (tail args) "" >>= \c -> putStrLn c
    let program_string = pack $ unwords args ++ " has finished"
    sendText program_string

checkAuth :: IO ()
checkAuth = do
    val <- lookupEnv "TEXTME_AUTH"
    unless (isJust val) $ do
        auth_token <- getInput "Auth Token: "
        setEnv "TEXTME_AUTH" auth_token

main = do
    args <- getArgs  
    parseArgs args


