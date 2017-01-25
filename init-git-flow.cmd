@echo off

rem Use this script for configure git flow plugin for this project.

rem Check gitflow is installed
echo Check gitflow version
git flow version
if errorLevel 1 (
	echo GitFlow extensions is not installed. Break process.
	exit 1
)

echo Configure gitflow paramters
rem First init gitflow with default parameters
git flow init -d

rem Set main branch names:
git config gitflow.branch.master master
git config gitflow.branch.develop dev

rem Set branch prefixes:
git config gitflow.prefix.feature feature/
git config gitflow.prefix.bugfix bugfix/
git config gitflow.prefix.release release/
git config gitflow.prefix.hotfix hotfix/
git config gitflow.prefix.support support/
git config gitflow.prefix.versiontag v

rem Set hooks path for project:
set CURRENT_DIR=%cd%
set HOOKS_TARGET_DIR=%CURRENT_DIR%\.git\hooks
set HOOKS_SOURCE_DIR=%CURRENT_DIR%\hooks
git config gitflow.path.hooks %HOOKS_TARGET_DIR% 

echo Copy hooks
rem Copy hooks
xcopy /S /Y /Q %HOOKS_SOURCE_DIR% %HOOKS_TARGET_DIR%

echo Configured