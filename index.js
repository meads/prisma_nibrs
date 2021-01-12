import { PrismaClient } from '@prisma/client'
// const {PrismaClient} = require('@prisma/client')
const prisma = new PrismaClient()
// use `prisma` in your application to read and write data in your DB

prisma.agencies.findMany({
    select: {
        pub_agency_name: true,
        state_postal_abbr: true
    }
}).then(console.log);