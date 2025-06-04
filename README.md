# TA-ECE263

This repository contains MATLAB scripts used for grading **Project 2 submissions** in the *ECE 263* course.

## Overview

The primary script, `autograder.m`, automates the evaluation process for student submissions by:

- Checking coding rule compliance using `RuleCheckerPlusPlus.m`
- Providing immediate feedback on violations
- Simplifying the grading workflow for TAs

## Usage

1. Open `autograder.m` and update the student list accordingly.
2. Place each student's submission (e.g., `.m` files) in the same directory as the script.
3. Run the script in MATLAB.

Feedback for each submission will be displayed in the Command Window and optionally saved for records.

## Files

- `autograder.m` – Main script to iterate through submissions
- `RuleCheckerPlusPlus.m` – Custom function for identifying rule violations in code
