.cd "D:/Studium/5. Semester/Grundlagen in R/Survey-Analysis/res/Developer_Survey_2019"

.open survey_results.db

.nullvalue NA

(.show)

CREATE TABLE IF NOT EXISTS "survey"(
  "Respondent" INTEGER PRIMARY KEY,
  "MainBranch" TEXT,
  "Hobbyist" TEXT,
  "OpenSourcer" TEXT,
  "OpenSource" TEXT,
  "Employment" TEXT,
  "Country" TEXT,
  "Student" TEXT,
  "EdLevel" TEXT,
  "UndergradMajor" TEXT,
  "EduOther" TEXT,
  "OrgSize" TEXT,
  "DevType" TEXT,
  "YearsCode" TEXT,
  "Age1stCode" TEXT,
  "YearsCodePro" TEXT,
  "CareerSat" TEXT,
  "JobSat" TEXT,
  "MgrIdiot" TEXT,
  "MgrMoney" TEXT,
  "MgrWant" TEXT,
  "JobSeek" TEXT,
  "LastHireDate" TEXT,
  "LastInt" TEXT,
  "FizzBuzz" TEXT,
  "JobFactors" TEXT,
  "ResumeUpdate" TEXT,
  "CurrencySymbol" TEXT,
  "CurrencyDesc" TEXT,
  "CompTotal" INTEGER,
  "CompFreq" TEXT,
  "ConvertedComp" INTEGER,
  "WorkWeekHrs" REAL,
  "WorkPlan" TEXT,
  "WorkChallenge" TEXT,
  "WorkRemote" TEXT,
  "WorkLoc" TEXT,
  "ImpSyn" TEXT,
  "CodeRev" TEXT,
  "CodeRevHrs" REAL,
  "UnitTests" TEXT,
  "PurchaseHow" TEXT,
  "PurchaseWhat" TEXT,
  "LanguageWorkedWith" TEXT,
  "LanguageDesireNextYear" TEXT,
  "DatabaseWorkedWith" TEXT,
  "DatabaseDesireNextYear" TEXT,
  "PlatformWorkedWith" TEXT,
  "PlatformDesireNextYear" TEXT,
  "WebFrameWorkedWith" TEXT,
  "WebFrameDesireNextYear" TEXT,
  "MiscTechWorkedWith" TEXT,
  "MiscTechDesireNextYear" TEXT,
  "DevEnviron" TEXT,
  "OpSys" TEXT,
  "Containers" TEXT,
  "BlockchainOrg" TEXT,
  "BlockchainIs" TEXT,
  "BetterLife" TEXT,
  "ITperson" TEXT,
  "OffOn" TEXT,
  "SocialMedia" TEXT,
  "Extraversion" TEXT,
  "ScreenName" TEXT,
  "SOVisit1st" TEXT,
  "SOVisitFreq" TEXT,
  "SOVisitTo" TEXT,
  "SOFindAnswer" TEXT,
  "SOTimeSaved" TEXT,
  "SOHowMuchTime" TEXT,
  "SOAccount" TEXT,
  "SOPartFreq" TEXT,
  "SOJobs" TEXT,
  "EntTeams" TEXT,
  "SOComm" TEXT,
  "WelcomeChange" TEXT,
  "SONewContent" TEXT,
  "Age" REAL,
  "Gender" TEXT,
  "Trans" TEXT,
  "Sexuality" TEXT,
  "Ethnicity" TEXT,
  "Dependents" TEXT,
  "SurveyLength" TEXT,
  "SurveyEase" TEXT
);

.mode csv

.import survey_results_public.csv survey_results

delete from survey_results where typeof([Respondent]) == "text";

create index [Respondent] on survey_results([Respondent]);

.exit

# Instruction on converting a csv file to a sqlite database

These instructions are tested on Windows and the following requirements.

## Requirements
* [SQLiteStudio (3.2.1)](https://github.com/pawelsalawa/sqlitestudio/releases/tag/3.2.1)
* [SQLite Version 3.34.0](https://www.sqlite.org/releaselog/3_34_0.html)
* [Notepad++ v7.9.1](https://notepad-plus-plus.org/downloads/v7.9.1/)

## Instructions
### Change eol of csv file
### Create database and table in SQLiteStudio
### Import csv into table