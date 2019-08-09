/**
 * routes.ui.index.ts
 * Provide a route for all UI routes
 */

// Node Modules
import { createReadStream } from 'fs'
import { resolve, join } from 'path'

// NPM Modules
import { Router, Request, Response } from 'express'

// Local Modules
import { tokenValidation } from './../middleware/authentication'
import authRoutes from './login'
import verifyRoutes from './verification'
import { getServerStatus, getHostname } from '../../lib/utils'
import { simpleQuery } from '../../lib/queries'
import { authorize } from '../middleware/authorization'
import Towel from '../../lib/queries/towel/towel'
// import * as routes from '../../../../service-tomorrow-client/server'
// import * as routes from 'serve-client'

export default function(): Promise<Router> {
  return new Promise((resolveRoutes, rejectRoutes) => {
    const uiRoutes = Router()

    uiRoutes.use(tokenValidation())
    uiRoutes.use('/auth', authRoutes)
    uiRoutes.use('/verify', verifyRoutes)

    uiRoutes.get(
      '/stats',
      authorize('administrator', (req: Request, res: Response) => {
        getServerStatus().then((stats) => {
          res.status(200).json(stats)
        })
      })
    )

    // If nginx is in use, /wetty will auto proxy pass to the locally running instance.
    // If it's made it this far, then wetty is not running
    uiRoutes.get('/wetty', (req: Request, res: Response) => {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' })
      const fileStream = createReadStream(
        resolve(__dirname, '../../../static/wettyError.html')
      )
      fileStream.on('data', (data) => {
        res.write(data)
      })
      fileStream.on('end', () => {
        res.end()
        return
      })
    })

    /*
      Require routes from the sys_route_module table.
    */
    new Towel('sys_route_module').setFields(['routing', 'file_path'])
    simpleQuery(
      'SELECT routing, file_path FROM sys_route_module WHERE (host = ? OR host = ?) AND pre_auth = 0',
      [getHostname(), '*']
    )
      .then(
        (results: { file_path: string; routing: string }[]): Promise<void> => {
          return new Promise(
            (
              resolveRouteResolved: () => void,
              rejectRouteResolved: (e: Error) => void
            ): void => {
              results.forEach((moduleInfo) => {
                try {
                  const routeHandler = require(moduleInfo.file_path)
                  console.log(
                    '[STARTUP] Using module located at %s for route %s',
                    moduleInfo.file_path,
                    moduleInfo.routing
                  )
                  uiRoutes.use(moduleInfo.routing, routeHandler)
                } catch (e) {
                  console.error(
                    '[STARTUP] Could not require route located at %s for route %s',
                    join(__dirname, moduleInfo.file_path),
                    moduleInfo.routing
                  )
                  console.error(e)
                  return rejectRouteResolved(e)
                }
              })
              return resolveRouteResolved()
            }
          )
        }
      )
      .then(() => {
        uiRoutes.all(
          '*',
          (req: Request, res: Response): void => {
            res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' })
            const fileStream = createReadStream(
              resolve(__dirname, '../../../static/error404.html')
            )
            fileStream.on('data', (data) => {
              res.write(data)
            })
            fileStream.on('end', () => {
              res.end()
              return
            })
          }
        )
        return resolveRoutes(uiRoutes)
      })
      .catch((err: Error) => {
        console.error(
          '[STARTUP] Failed to load all requested routes with error:'
        )
        console.error(err)
      })
  })
}

// uiRoutes.get('*', (req: Request, res: Response) => {
//   if (req.auth.iA && req.auth.u) {
//     res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' })
//     const fileStream = createReadStream(
//       resolve(__dirname, '../../../../static/index.html')
//     )
//     fileStream.on('data', (data) => {
//       res.write(data)
//     })
//     fileStream.on('end', () => {
//       res.end()
//       return
//     })
//   } else {
//     res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' })
//     const fileStream = createReadStream(
//       resolve(__dirname, '../../../../static/login.html')
//     )
//     fileStream.on('data', (data) => {
//       res.write(data)
//     })
//     fileStream.on('end', () => {
//       res.end()
//       return
//     })
//   }
// })