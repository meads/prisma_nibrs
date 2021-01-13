"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NIBRS_API = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class NIBRS_API {
    constructor() { }
    getAllHomicides() {
        return __awaiter(this, void 0, void 0, function* () {
            var results = null;
            try {
                results = yield prisma.$queryRaw(`
                SELECT o.*
                FROM nibrs_offense o
                JOIN nibrs_incident ni ON o.incident_id = ni.incident_id
                JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id
                JOIN agencies c ON c.agency_id = nm.agency_id
                JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
                WHERE ot.offense_code = '09A';
            `);
            }
            catch (e) {
                console.log("Oops there was a problem fetching...");
                console.error(e);
            }
            return results;
        });
    }
}
exports.NIBRS_API = NIBRS_API;
(() => __awaiter(void 0, void 0, void 0, function* () {
    const homicides = yield new NIBRS_API().getAllHomicides();
    console.table(homicides);
}))();
//# sourceMappingURL=main.js.map