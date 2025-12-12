import express from 'express'
import pkg from 'pg'
const { Pool } = pkg

const PORT = process.env.PORT || 8084
const DATABASE_URL = process.env.DATABASE_URL
const STU_ID = process.env.STU_ID
const STU_GROUP = process.env.STU_GROUP
const STU_VARIANT = process.env.STU_VARIANT

const app = express()
app.use(express.json())

console.log(
  `[START] STU_ID=${STU_ID} STU_GROUP=${STU_GROUP} STU_VARIANT=${STU_VARIANT} PORT=${PORT}`
)

const pool = new Pool({ connectionString: DATABASE_URL, ssl: false })

app.get('/live', async (_req, res) => {
  try {
    await pool.query('SELECT 1')
    res.status(200).json({ status: 'ok' })
  } catch (e) {
    res.status(500).json({ status: 'db_error', message: e.message })
  }
})

app.get('/', (_req, res) => {
  res.json({ hello: 'world', variant: STU_VARIANT, student: STU_ID })
})

app.listen(PORT, () => {
  console.log(`[HTTP] Listening on :${PORT}`)
})
