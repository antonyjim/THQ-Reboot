/**
 * Start the web server
 */

import { readFile } from 'fs'

// Load environment variables
readFile('./dot.env', { encoding: 'utf8' }, (err: Error, data: string) => {
  if (err) {
    console.error(err)
    console.error(
      '[STARTUP] App could not read environment variables. Please check that dot.env exists in the root directory'
    )
    process.exit(1)
  }
  const lines: string[] | number[] = data.split('\n')
  lines.map((line: string) => {
    const key: string = line.split('=')[0]
    const value: string = line.split('=')[1]
    if (value[0] === "'") {
      console.log(
        '[STARTUP] Setting environment variable %s to value %s',
        key,
        value
      )
      process.env[key] = value.slice(1, -1)
    } else {
      process.env[key] = value
    }
  })
  // Start the web server
  require('./server/app').routes()
})