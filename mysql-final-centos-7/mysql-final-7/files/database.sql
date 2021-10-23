create database SpringDevOps2021;
use SpringDevOps2021;
create table SuperTek (
    student_ID varchar(5) NOT NULL,    
    first_name char(25) NOT NULL, 
    last_name char(30) NOT NULL,                   
    GPA int(3),
    state char(50),       
    primary key (student_ID)          
    );

INSERT INTO `SuperTek` VALUES ('AJ005','Alex','Johnson',95,'West Virginia'),('CH001','Chantelle','Michaels',75,'Maryland'),('JA002','Jacob','Sanders',69,'Michigan'),('JS007','John','Smith',87,'Tennesse'),('OL004','Oleg','Alexandrov',45,'District of Columbia'),('PK006','Peter','Kong',73,'North Carolina'),('VA003','Vadim','Ivanov',80,'Virginia');

create table Octagon (
    student_ID varchar(5) NOT NULL,    
    first_name char(25) NOT NULL, 
    last_name char(30) NOT NULL,                   
    GPA int(3),
    state char(50),       
    primary key (student_ID)          
    );

create table RogueBrains (
    student_ID varchar(5) NOT NULL,    
    first_name char(25) NOT NULL, 
    last_name char(30) NOT NULL,                   
    GPA int(3),
    state char(50),       
    primary key (student_ID)          
    );

create table Fortitude (
    student_ID varchar(5) NOT NULL,    
    first_name char(25) NOT NULL, 
    last_name char(30) NOT NULL,                   
    GPA int(3),
    state char(50),       
    primary key (student_ID)          
    );

create table Devoprockers (
    student_ID varchar(5) NOT NULL,    
    first_name char(25) NOT NULL, 
    last_name char(30) NOT NULL,                   
    GPA int(3),
    state char(50),       
    primary key (student_ID)          
    );

create table AplusTeam (
    student_ID varchar(5) NOT NULL,    
    first_name char(25) NOT NULL, 
    last_name char(30) NOT NULL,                   
    GPA int(3),
    state char(50),       
    primary key (student_ID)          
    );