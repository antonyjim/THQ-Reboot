
/**
 * lib/ql/API.ts
 * Provide API URL parsing and field validation
*/

// Node Modules


// NPM Modules


// Local Modules
import { Querynator } from "../../connection";
import { Log } from "../../log";
import { rootQueries } from "./queries";


// Constants and global variables

interface APIResponse {
    status: number,
    body: {
        errors?: [{
            message: string
        }?],
        data?: any
    }
}


export default class APICall extends Querynator {
    response: APIResponse

    constructor(context) {
        super(context)
        this.response = {
            status: 200,
            body: {
                errors: [],
                data: {}
            },
        }
    }

    protected sendResponse() {
        this.context.res.status(this.response.status).json(this.response.body)
    }

    /**
     * Log and handle any errors encountered in the resolver functions
     * @param err Error to be logged
     * @param terminatingError Whether the response should be sent or should wait until data is received
     */
    protected handleError(err: Error, terminatingError?: boolean) {
        const requestFailure = () => this.context.res.status(500).send(this.response.body)
        let message = ''
        if (typeof err === 'string') message = err
        else message = err.message

        this.response.body.errors.push({message})

        if (terminatingError) {
            requestFailure()
            new Log(message).error(3)          
        } else {
            new Log(message).error(4)
        }
    }

    private async verifyFields(fields: string[]) {
        let query = 'SELECT column_name, type, length FROM sys_db_dictionary WHERE table_name = ?'
        let params = [this.context.req.params.table || false]
        let validFields: string[] = []
        let format = await this.createQ({query, params}, 'CALL')
        .catch((err: Error) => this.handleError(err))
        if (format.length > 0 && fields.length > 0) {
            format.map(field => {
                if (fields.includes(field.column_name)) validFields.push(field.column_name)  
            })
        } else if (format.length > 0 && fields.length < 0) {
            format.FIELDS.map(field => {
                if (field.default_view) validFields.push(field.column_name)  
            })
        } else {
            validFields.push('*')
        }

        Promise.resolve(validFields)
    }

    protected prepareQuery() {

    }

    public create() {

    }

    /**
     * Sample query: /api/q/user_list?fields=userId,userName,userFirstName,userLastName&args=userId=eq|29b7b057-9438-4d01-9bc5-b94387e3f51e
     */
    public query() {
        this.on('validatedFields', (e) => {
            let rawArgs = this.context.req.query.args
            let args: any = {}
            let queryTable = this.context.req.params.table
            if (rawArgs && rawArgs.length > 0) {
                rawArgs.split(',').map(arg => {
                    let keyVal = arg.split('=')
                    args[keyVal[0]] = keyVal[1]
                })
            }
            // If both the ID and table is provided, query the single record
            console.log('%s, %s, %s, %s', queryTable, this.context.req.params.id, rootQueries[queryTable], fields)
            if (this.context.req.params.table
            && this.context.req.params.id
            && rootQueries[queryTable]) {
                rootQueries[queryTable](fields, args, this.context)
                .then(rows => {
                    this.response.body.data = rows
                    this.response.status = 200
                    this.sendResponse()
                }, failure => {
                    this.handleError(failure, true)
                })
                .catch(err => this.handleError(err, true))
            } else if (queryTable) {
                let pagination = {
                    limit: this.context.req.query.limit || 20,
                    offset: this.context.req.query.offset || 0
                }
                rootQueries[queryTable](fields, args, this.context, pagination)
                .then(rows => {
                    this.response.body.data[queryTable] = rows
                    this.response.status = 200
                    this.sendResponse()
                }, failure => {
                    this.handleError(failure, true)
                })
                .catch(err => this.handleError(err, true))
            } else {
                this.handleError(new Error(`No data associated with request`), true)
            }
        })
        let fields = this.context.req.query.fields
        if (fields && fields.length > 0) {
            fields = fields.split(',')
            if (rootQueries[this.context.req.params.table]) {
                this.emit('validatedFields')
            } else {
                return this.handleError(new Error(`Table ${this.context.req.params.table} does not exist.`), true)
            }
            /*
            this.verifyFields(fields.split(','))
            .then(validFields => {
                fields = validFields
                this.emit('validatedFields')
            })
            .catch(err => {
                new Log(err.message).error(3)
                this.handleError(new Error(`Table ${this.context.req.params.table} does not exist.`), true)
            })
            */
        } else {
            this.verifyFields([])
            .then(defaultFields => {
                fields = defaultFields
                this.emit('validatedFields')
            })
            .catch(err => {
                new Log(err.message).error(3)
                this.handleError(new Error(`Table ${this.context.req.params.table} does not exist.`), true)
            })
        }
    }
}