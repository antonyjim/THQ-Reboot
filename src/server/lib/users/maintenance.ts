/**
 * users.maintenance.ts
 * Provide utilities for creating and modifying user accounts and nonsigs
*/

// Node Modules


// NPM Modules
import * as uuid from 'uuid'
import { hashSync } from 'bcrypt'
import { sign, verify } from 'jsonwebtoken'

// Local Modules
import { UserTypes } from '../../types/users'
import { Validation } from '../validation'
import { StatusMessage } from '../../types/server';
import { getPool, jwtSecret } from '../connection';
import { sendConfirmation, sendFailedPasswordReset, sendPasswordReset } from '../email/emails';
import { NonsigTypes } from '../../types/nonsig';


// Constants and global variables
const pool = getPool()
const saltRounds = 10

export class Nonsig {
    nonsig: NonsigTypes.nsInfo

    /**
     * @param ns Nonsig information
     */
    constructor(ns) {
        this.nonsig = ns
        this.normalizeNonsig()
    }

    private normalizeNonsig() {
        let nonsig = this.nonsig.nsNonsig
        if (nonsig.length < 9) {
            while (nonsig.length < 9) nonsig = '0' + nonsig
            this.nonsig.nsNonsig = nonsig
            return 0
        } else if (nonsig.length > 9) {
            this.nonsig.nsNonsig = nonsig.slice(0, 9)
            return 0
        } else {
            return 0
        }
    }

    private checkForExistingNonsig(nsNonsig) {
        return new Promise((resolve, reject) => {
            let sql = `
                SELECT *
                FROM nsInfo
                WHERE nsNonsig = ${pool.escape(nsNonsig)}
            `
            pool.query(sql, (err: Error, results) => {
                if (err) {
                    throw {
                        error: true,
                        message: err
                    }
                } else {
                    if (results.length > 0) {
                        reject({
                            error: true,
                            message: 'Nonsig already exists',
                            details: results
                        })
                    } else {
                        resolve({
                            error: false,
                            message: 'Nonsig does not exist'
                        })
                    }
                }
            })
        })
    }

    public create() {
        return new Promise((resolve, reject) => {
            let validator = new Validation(this.nonsig)
            let invalidFields = validator.defaults(
                [
                    'nsTradeStyle',
                    'nsNonsig',
                    'nsAddr1',
                    'nsCity',
                    'nsPostalCode',
                    'nsCountry',
                    'nsType'
                ]
            )
            if (invalidFields) {
                reject({
                    error: true,
                    message: 'Missing required fields',
                    details: invalidFields
                })
            } else {
                this.checkForExistingNonsig(this.nonsig.nsNonsig)
                .then((onSuccess: StatusMessage) => {
                    let nsToAdd = validator.defaults({
                        nsId: uuid.v4(),
                        nsIsActive: true,
                        nsIsActiveTHQ: true,
                        nsAddr2: null,
                        nsBrandKey: null
                    })
                    let insertionSql = `
                        INSERT INTO
                            nsInfo (
                                nsId,
                                nsTradeStyle,
                                nsNonsig,
                                nsAddr1,
                                nsAddr2,
                                nsCity,
                                nsState,
                                nsPostalCode,
                                nsCountry,
                                nsBrandKey,
                                nsIsActive,
                                nsIsActiveTHQ,
                                nsType
                            )
                        VALUES (
                            ${pool.escape([
                                nsToAdd.nsId,
                                nsToAdd.nsTradeStyle,
                                nsToAdd.nsNonsig,
                                nsToAdd.nsAddr1,
                                nsToAdd.nsAddr2,
                                nsToAdd.nsCity,
                                nsToAdd.nsState,
                                nsToAdd.nsPostalCode,
                                nsToAdd.nsCountry,
                                nsToAdd.nsBrandKey,
                                nsToAdd.nsIsActive,
                                nsToAdd.nsIsActiveTHQ,
                                nsToAdd.nsType
                            ])}
                        )
                    `
                    pool.query(insertionSql, (err: Error, results) => {
                        if (err) {
                            throw {
                                error: true,
                                message: err
                            }
                         } else {
                            resolve({
                                error: false,
                                message: 'Added nonsig',
                                details: nsToAdd
                            })
                         }
                    })
                }, (onFailure: StatusMessage) => {
                    reject(onFailure)
                })
                .catch((err: StatusMessage) => {
                    reject(err)
                })
            }
        })
    }

    public existsAndIsActive(): Promise<{error: boolean, isActiveTHQ: boolean, isActive: boolean}> {
        return new Promise((resolve, reject) => {
            let sql = `
                SELECT nsNonsig, nsIsActive, nsIsActiveTHQ
                FROM nsInfo
                WHERE nsNonsig = ${pool.escape(this.nonsig.nsNonsig)}
            `
            pool.query(sql, (err: Error, results: Array<NonsigTypes.nsInfo>) => {
                if (err) {
                    err
                } else {
                    if (results.length === 1) {
                        const nonsig = results[0]
                        if(nonsig.nsIsActive && nonsig.nsIsActiveTHQ) {
                            resolve({
                                error: false,
                                isActiveTHQ: true,
                                isActive: true
                            })
                        } else if (nonsig.nsIsActive && !nonsig.nsIsActiveTHQ) {
                            resolve({
                                error: false,
                                isActiveTHQ: false,
                                isActive: true
                            })
                        } else {
                            resolve({
                                error: false,
                                isActiveTHQ: false,
                                isActive: false
                            })
                        }
                    } else {
                        reject({
                            error: true,
                            message: 'No nonsig found'
                        })
                    }
                }
            })
        })
    }
} // Nonsig

export class User {
    userOpt: UserTypes.All

    /**
     * Create, edit, destroy users
     */
    constructor(options: UserTypes.All) {
        this.userOpt = options
    }

    private clearPasswordResets() {
        if(!this.userOpt.userId) {
            return 1
        } else {
            let sql = `
                UPDATE userRegistration
                SET userConfirmation = NULL
                WHERE userId = ${pool.escape(this.userOpt.userId)}
            `
            pool.query(sql, (err: Error, results) => {
                return 1
            })
        }
    }

    /*
    private newAccount(accountOpts: UserTypes.All): Promise<StatusMessage> {
        return new Promise((resolve, reject) => {
            pool.query(
                `SELECT * 
                FROM userRegistration
                WHERE userName = ${pool.escape(accountOpts.userName)}
                    OR userId = ${pool.escape(accountOpts.userId)}
                    OR userEmail = ${pool.escape(accountOpts.userEmail)}`,
                function(err: Error, results: Array<UserTypes.LoginInfo>) {
                    if (err) {throw err}
                    if (results.length > 0) {
                        let reason: StatusMessage = {
                            error: true,
                            message: 'Username or ID or Email already exist'
                        }
                        reject(reason)
                    } else {
                        new Nonsig({nsNonsig: accountOpts.userDefaultNonsig}).existsAndIsActive()
                        .then((nonsigExists) => {
                            if(nonsigExists.isActive && nonsigExists.isActiveTHQ) {
                                pool.query(
                                    `CALL newUser (
                                        ${pool.escape([
                                            accountOpts.userId,
                                            accountOpts.userName.toLowerCase(),
                                            null,
                                            accountOpts.userEmail.toLowerCase(),
                                            accountOpts.userDefaultNonsig,
                                            (accountOpts.userIsLocked === true ? 1 : 0),
                                            0,
                                            accountOpts.userFirstName,
                                            accountOpts.userLastName,
                                            accountOpts.userPhone,
                                            accountOpts.userConfirmation
                                        ])})`,
                                    function(err: Error, results) {
                                        if (err) {throw err}
                                        let reason: StatusMessage = {
                                            error: false,
                                            message: 'User account created successfully'
                                        }
                                        let confirmationToken = sign({
                                            t: accountOpts.userConfirmation,
                                            action: 'r'
                                        },
                                        jwtSecret,
                                        {
                                            expiresIn: '30d'
                                        })
                                        sendConfirmation(
                                            {
                                                userEmail: accountOpts.userEmail, 
                                                confirmationToken
                                            }
                                        )
                                        .then(onEmailSent => {
                                            resolve(reason)
                                        }, onEmailNotSent => {
                                            reject(onEmailNotSent)
                                        })
                                        .catch(err => {
                                            throw err
                                        })
                                })
                            } else {
                                reject({
                                    error: true,
                                    message: 'Nonsig is not active'
                                })
                            }
                        }, (nonsigDoesNotExist) => {
                            reject(nonsigDoesNotExist)
                        })
                        .catch(err => {
                            throw err
                        })
                    }
                }
            )
        })
    } // newAccount() */

    public confirmAccount(password1, password2) {
        return new Promise((resolve, reject) => {
            if (
                this.userOpt.userConfirmation 
                && password1 
                && password2
            ) {
                verify(this.userOpt.userConfirmation, jwtSecret, (err, decoded: {t: string, g: string}) => {
                    if (err) {
                        if (err.name === 'TokenExpiredError' && decoded.g === 'r') {
                            reject({
                                error: true,
                                message: 'Account was not confirmed within 30 days. Please reregister.'
                            })
                        } else if (err.name === 'TokenExpiredError' && decoded.g === 'h') {
                            reject({
                                error: true,
                                message: 'Password was not reset within 1 hour. Please click on forgot password to restart password reset process.'
                            })
                        } else {
                            reject({
                                error: true,
                                message: 'Token is not valid. Please click on forgot password'
                            })
                        }
                    } else {
                        if (decoded.t) {
                            let hashed: string = ''
                            try {
                                hashed = this.verifyAndHashPassword(password1, password2)
                            } catch(err) {
                                reject({
                                    error: true,
                                    message: err.message
                                })
                            }
                            console.log(hashed)
                            let confirmUser = `
                                SELECT confirmUser(
                                    ${pool.escape([
                                        decoded.t,
                                        hashed
                                    ])}
                                ) AS confirmed
                            `
                            console.log(confirmUser)
                            pool.query(confirmUser, (err: Error, results) => {
                                if (err) {
                                    throw err
                                 } else {
                                    if (results[0].confirmed === 0) {
                                        resolve({
                                            error: false,
                                            message: 'Confirmed'
                                        })
                                    } else {
                                        reject({
                                            error: true,
                                            message: 'Key does not match confirmation.'
                                        })
                                    }
                                 }
                            })
                        } else {
                            reject({
                                error: true,
                                message: 'Missing user id or confirmation key.'
                            })
                        }
                    }
                })
            } else {
                reject({
                    error: true,
                    message: 'Missing User Id or Password or confirmation token'
                })
            }
        })
    }

    public forgotPassword() {
        function setConfirmation(id: string, unique: string) {
            let updateConf = `
                UPDATE userRegistration
                SET 
                    userConfirmation = ${pool.escape(unique)},
                    userAwaitingPassword = 1
                WHERE userId = ${pool.escape(id)}
            `
            pool.query(updateConf, (err: Error, results) => {
                if (err) {
                    console.error('Error setting password confirmation, ', err)
                }
            })
        }
        let sql = `
            SELECT 
                userEmail, 
                userId
            FROM userRegistration
            WHERE userEmail = ${pool.escape(this.userOpt.userEmail)}
        `
        pool.query(sql, (err: Error, results) => {
            if (err) {
                console.error(err)
                sendFailedPasswordReset(this.userOpt.userEmail)
             } else {
                if(results.length === 1) {
                    console.log('User exists')
                    let uniqueReset = uuid.v4()
                    setConfirmation(results[0].userId, uniqueReset)
                    sign({t: uniqueReset, g: 'h'}, jwtSecret, (err: Error, token: string) => {
                        if(err) console.error(err)
                        sendPasswordReset(this.userOpt.userEmail, token)
                    })
                } else {
                    console.log('user does not exist')
                    sendFailedPasswordReset(this.userOpt.userEmail)
                }
             }
        })
    }

    public verifyUsername() {
        return new Promise((resolve, reject) => {
            if (!this.userOpt.userName || !this.userOpt.userEmail) {
                throw new TypeError('No username or email provided to verify user against')
            } else {
                let conditions = []
                let sql = `
                    SELECT userName, userEmail
                    FROM userRegistration
                    WHERE
                `
                if (this.userOpt.userName) {
                    conditions.push(`userName = ${pool.escape(this.userOpt.userName.toLowerCase())}`)
                }
                if (this.userOpt.userEmail) {
                    conditions.push(`userEmail = ${pool.escape(this.userOpt.userEmail.toLowerCase())}`)
                }
                sql += conditions.join(' OR ')
                pool.query(sql, (err: Error, results: Array<any>) => {
                    if (err) {
                        throw err
                     } else {
                        if (results.length === 0) {
                            resolve({
                                error: false,
                                message: 'Username available'
                            })
                        } else {
                            let message: Array<string> = []
                            for(let user of results) {
                                if (user.userEmail === this.userOpt.userEmail) {
                                    message.push('Email already in use. Please click on forgot password') 
                                } else if (user.userName === this.userOpt.userName) {
                                    message.push('Username already in use')
                                } else {
                                    message.push('User already exists')
                                }
                            }
                            resolve({
                                error: true,
                                message
                            })
                        }
                     }
                })
            }
        })
    }

    private verifyAndHashPassword(password1, password2): string {
        if (password1 !== password2) {
            throw new TypeError('Passwords do not match')
        } else if (!/[A-Z]/.test(password1)) {
            message: 'Passwords should contain an uppercase letter'
        } else if (!/[0-9]/.test(password1)) {
            throw new TypeError('Passwords should contain a number')
        } else if (password1.length < 8) {
            throw new TypeError('Password needs to be at least 8 characters long')
        } else if (password1.length > 50) {
            throw new TypeError('Passwords can not be over 50 characters long')
        } else {
            return hashSync(password1, saltRounds)
        }
    }

    public setPassword(password1, password2) {
        return new Promise((resolve, reject) => {
            if (this.userOpt.userId) {
                let hashed: string = ''
                try {
                    hashed = this.verifyAndHashPassword(password1, password2)
                } catch (err) {
                    reject({
                        error: true,
                        message: err.message
                    })
                }
                const sql = `
                    UPDATE userRegistration
                    SET 
                        userPass = ${pool.escape(hashed)}
                    WHERE 
                        userId = ${pool.escape(this.userOpt.userId)}
                `
                console.log(sql)
                pool.query(sql, (err: Error, results) => {
                    if (err) {throw err}
                    resolve({
                        error: false,
                        message: "Password set successfully."
                    })
                })
            } else {
                reject({
                    error: true,
                    message: 'Missing userId'
                })
            }
        })
    } // setPassword()

    /*
    public createNew(): Promise<StatusMessage> {
        return new Promise((resolve, reject) => {
            this.userOpt.userId = uuid.v4()
            let requiredFields = [
                'userName',
                'userEmail',
                'userNonsig',
                'userPhone',
                'userFirstName',
                'userLastName'
            ]
            let validator = new Validation(this.userOpt)
            let invalidFields = validator.required(requiredFields)
            if (invalidFields.length > 0) {
                reject({
                    error: true,
                    message: 'Invalid data',
                    details: invalidFields
                }) 
            } else {
                let defaultedFields = validator.truncate(
                    [
                        {
                            field: 'userName',
                            length: 36
                        },
                        {
                            field: 'userEmail',
                            length: 90
                        },
                        {
                            field: 'userDefaultNonsig',
                            length: 9
                        },
                        {
                            field: 'userFirstName',
                            length: 30
                        }, 
                        {
                            field: 'userLastName',
                            length: 30
                        }
                    ]
                ).defaults(
                    {
                        userId: uuid.v4(),
                        userConfirmation: uuid.v4()
                    }
                )
                this.newAccount(defaultedFields)
                .then(function(resolvedPromise) {
                    resolve(resolvedPromise) 
                }, function(rejectedPromise) {
                    reject(rejectedPromise)
                })
                .catch(function(err) {
                    throw err
                }) 
            }
        })
    } // createNew()
    */
}