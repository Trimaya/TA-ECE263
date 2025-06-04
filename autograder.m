clear;clc;
students = {"Abdulrehman","Ahmed","AliAlDorzi","Bayan","Gokul","Itzel","Jiahao","Mayar","Nora","Regina","Siraj","Sohail","Ziwei"};
for i = 1:length(students)
    student = string(students(i));
    load("data\"+student+"data.mat");
    disp(student)
    RuleCheckerPlusPlus(data)
    % diary(student+"_rulecheck.txt")
    % RuleChecker(data)
    % diary off
end