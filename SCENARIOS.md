# Scenarios

## First look

Take a first look at the system.

* What problems can you spot with the code?
* What looks most dangerous?

Get the code running.  Which of those problems can you exploit?

Which actually appear to be easily exploitable?

Note that the [WORKSTATION-SETUP](WORKSTATION-SETUP.md) document has
instructions on how to [setup admin users](WORKSTATION-SETUP.md#adding-an-admin-user)
so that you can test everything locally.

### Hints

* Check the logs
* Log more things - see [Environment variables](DEVELOPING.md#environment-variables]
  in the development guide
* The things that look most obviously broken may not be the simplest things to exploit
* The Fish and Chips feature is good place to start.

## Attack detected

An attack was detected against the system.  We have [nginx logs](https://gist.github.com/colinnewell/12f3f60bc966dd1af65ab262f2c89a2f).

Figure out what the attacker did and what they exploited.  See what data they
retrieved by examining the logs closely.
