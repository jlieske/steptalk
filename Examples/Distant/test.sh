#!/bin/csh


# stenvironment -name TestEnvironment

echo "text := 'Hello StepTalk.'" | stexec -env TestEnvironment
echo "Transcript showLine:text" | stexec -env TestEnvironment
