import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

export class NIBRS_API {
    constructor(){}
    async getAllHomicides(){
        var results = null
        try {
            
            results = await prisma.$queryRaw(`
                SELECT o.*
                FROM nibrs_offense o
                JOIN nibrs_incident ni ON o.incident_id = ni.incident_id
                JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id
                JOIN agencies c ON c.agency_id = nm.agency_id
                JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
                WHERE ot.offense_code = '09A';
            `)
        } catch(e) {
            console.log("Oops there was a problem fetching...")
            console.error(e)
        }
        return results
    }
}
(async () => {
    const homicides = await new NIBRS_API().getAllHomicides()
    console.table(homicides)
})()
