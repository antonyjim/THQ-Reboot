/**
 * app.ts
 * Provide an entry point for the THQ application
 */

// Node Modules
import * as cluster from 'cluster'
import { cpus } from 'os'
import { createReadStream } from 'fs'
import { resolve } from 'path'

// NPM Modules
import * as express from 'express'

// Local Modules
import { router } from './routes/index'
import { Log } from './lib/log'
import { getPool } from './lib/connection'
import constructSchema from './app/model/constructSchema'
import { constructForms } from './app/model/constructForms'
import generateHooks from './app/model/generateHooks'
import { syncDbSchema } from './app/model/dbSchemaGen'
import { Server } from 'http'

/**
 * Starts requiring all of the routes for the core plus any activated modules.
 */
export function routes() {
  if (process.env.NODE_ENV === 'production') {
    const cores: number = cpus().length
    if (cluster.isMaster) {
      console.log('Started cluster, master process as ' + process.pid)
      let i: number = parseInt(process.env.CLUSTER_COUNT, 10) || cores
      while (i >= 0) {
        cluster.fork()
        i--
      }

      cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker process ${worker.process.pid} crashed`)
      })
    } else {
      listen()
    }
  } else {
    listen()
  }

  function listen() {
    // Constants and global variables
    const app = express()
    const port = parseInt(process.env.SERVER_PORT, 10) || 8020
    let server: Server
    // Routes
    app.disable('x-powered-by')
    app.use('/', router)
    process.on('SIGTERM', (e) => {
      getPool().end()
      server.close()
      new Log('Pool connections closed').info()
    })

    // @ts-ignore
    global.app = app

    syncDbSchema()
      .then(constructSchema)
      .then((tables) => {
        // We need to assign the resulting tables object to **something** so that
        // the garbage collector does not collect it.
        app.schema = tables
        console.log('Completed bulding schema')
        server = app.listen(port, () => {
          new Log(`Listening at port ${port} on process ${process.pid}`).info()
        })
        return constructForms()
      })
      .then(() => {
        console.log('[STARTUP] Finished constructing forms')
        generateHooks()
      })
      .catch((err) => {
        console.error(
          `[CONSTRUCT_SCHEMA] CRITICAL ERROR WHEN STARTING SERVER ${
            err.message
          }`
        )
        getPool().end()
      })
  }
}

/**
 * Exports a simple html page telling the user to come back with a warrant.
 */
export function internalError() {
  const app = express()
  const port = parseInt(process.env.SERVER_PORT, 10) || 8020

  app.get('*', (req, res) => {
    try {
      res.writeHead(200, { 'Content-Type': 'text/html' })
      createReadStream(resolve(__dirname, '../static/error505.html')).pipe(res)
    } catch (err) {
      res.send('<html>Internal server error</html>')
    }
  })

  app.listen(port, () => {
    console.log('[APP] Listening for fallback on port %d', port)
  })
}
