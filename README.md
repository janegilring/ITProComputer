# Manage your IT Pro computer using PowerShell

This repository contains artifacts for managing your IT Pro computer using PowerShell, as demonstrated in the presentation *Manage your IT Pro computer using PowerShell* presented by Jan Egil Ring at PowerShell Summit Europe 2015

**Session description**

*Are you reluctant about re-installing your IT Pro computer where you have so much software installed and tweaked to fit your needs and environment? 
Join this session to see how this process can be largely automated by leveraging the PackageManagement and PowerShellGet modules. 
We`ll also look at how to set up your PowerShell profile to be synchronized and customized for different environments, such as your home computer, your virtual machine used for VPN, your computer at work and so on.*

[A recording of the session is available on YouTube.](https://www.youtube.com/watch?v=eJwoDZYXf1E)

## Prerequisites
The scripts and configurations in this repository is targeted at Windows 10 RTM running the 2015 November update (10586.318) or later. Parts of it may run on older client operating systems with Windows Management Framework 5 or later installed, but parts of the configuration is targeting Windows 10 specifically (new features such as Snap Assist and Snap Fill). 

## Getting started
Copy the [raw contents](https://raw.githubusercontent.com/janegilring/ITProComputer/master/Initialize-Repository.ps1) of Initialize-Repository.ps1 to a new PowerShell ISE session, and run it line by line.

## Change-log
- 2015-09-10 - Initial version
- 2016-05-25 - Using new [Chocolatey](https://chocolatey.org) version (choco.exe) and cChoco DSC Resource instead of old experimental OneGet provider and custom DSC Resource. Updated self signed certificate generation to be WMF 5 RTM compatible. Updated initalization script to run on a regular Windows 10 computer - dependencies of Crayon Demo environment removed.