# Contributing

## Reporting Issues or Bug Reports

Bug reports are appreciated. Read [**`Issues - Bug Reports`**](https://github.com/asistex/ighoo/blob/master/.github/DOCS/pullreq_1.md) for a few guidelines listed will help speed up the process of getting them fixed.


---
### [1- Go to **Tab Issue -> New Issue**](https://github.com/asistex/ighoo/issues/new/choose)

[![image](https://github.com/asistex/ighoo/blob/master/.github/ISSUE_TEMPLATE/btn_issue.jpg)](https://github.com/asistex/ighoo/issues/new/choose)

---
### [2- click on **Get Started**](https://github.com/asistex/ighoo/issues/new?assignees=&labels=&template=bug_report.md&title=)

[![image](https://github.com/asistex/ighoo/blob/master/.github/ISSUE_TEMPLATE/Start.jpg)](https://github.com/asistex/ighoo/issues/new?assignees=&labels=&template=bug_report.md&title=)

---
### [3- **Fill form**](https://github.com/asistex/ighoo/issues/new?assignees=&labels=&template=bug_report.md&title=)

[![image](https://github.com/asistex/ighoo/blob/master/.github/ISSUE_TEMPLATE/fill.jpg)](https://github.com/asistex/ighoo/issues/new?assignees=&labels=&template=bug_report.md&title=)

---


## Pull Requests

Your pull requests are welcome; however, they may not be accepted for various reasons.
Read [**`pull_request_template.md`**](https://github.com/asistex/ighoo/blob/master/.github/PULL_REQUEST_TEMPLATE/pull_request_template.md) for a few guidelines listed will help speed up the process of getting them fixed.
All Pull Requests, except for translations and user documentation, need to be attached to a issue on GitHub. For Pull Requests regarding enhancements and questions, the issue must first be approved by one of project's administrators before being merged into the project. An approved issue will have the label **`Accepted`**. For issues that have not been accepted, you may request to be assigned to that issue.

Opening a issue beforehand allows the administrators and the community to discuss bugs and enhancements before work begins, preventing wasted effort.


### Guidelines for pull requests

1. Respect HMG Harbour coding style.
2. Create a new branch for each PR. **`Make sure your branch name wasn't used before`** - you can add date (for example `patch3_20200528`) to ensure its uniqueness.
3. Single feature or bug-fix per PR.
4. Make single commit per PR.
5. Make your modification compact - don't reformat source code in your request. It makes code review more difficult.

In short: The easier the code review is, the better the chance your pull request will get accepted.


### Coding style

#### GENERAL

1. ##### Use the following indenting for statements. 3 spaces, NO tabs:

  * ###### Good:
    ```
    SWITCH cnExp
       CASE condition
          IF someCondition == .T.
             DoSomething()
          ENDIF
          Exit

       CASE condition
          // code
          Exit

       OTHERWISE
          // code

    END SWITCH
    ```

  * ###### Bad:
    ```
    SWITCH cnExp
    CASE condition
    if someCondition == 37
    Do something
    Endif
    CASE condition
    // code
    Exit
    OTHERWISE
    // code
    END SWITCH    ```
    ```

2. ##### Avoid magic numbers.

  * ###### Good:
    ```
    if (foo < I_CAN_PUSH_ON_THE_RED_BUTTON)
        startThermoNuclearWar();
    ```

  * ###### Bad:
    ```
    while (lifeTheUniverseAndEverything != 42)
        lifeTheUniverseAndEverything = buildMorePowerfulComputerForTheAnswer();
    ```



#### NAMING CONVENTIONS

1. ##### Functions, Classes Methods & method parameters use camel Case

  * ###### Good:
    ```
    hb_aDel( aArray, nPos, .F. )
    ```

  * ###### Bad:
    ```
    hb_adel( aarray, POS, .f. )
    HB_AINS( array, Pos, Value, .t. )
    ```

2. ##### Always prefer a variable name that describes what the variable is used for.

  * ###### Good:
    ```
    IF ( nHours < 24 .And. nMinutes < 60 .And. nSeconds < 60)
    ```

  * ###### Bad:
    ```
    if (a < 24 .And. b < 60 .And. c < 60)
    ```



#### COMMENTS

1. ##### Use comment line style.

  * ###### Good:
    ```
    // Two lines comment
    // Use still C++ comment line style
    ```

  * ###### Bad:
    ```
    * Please don't piss me off with that asterisk
    ```

2. #### Multilines comments

   /*
    * comments
    * multilines
    */
