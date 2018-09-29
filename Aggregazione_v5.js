// Con questa aggregazione mi splitta le remit in ore, e mi restituisce quelle piu aggiornate a livello orario
// ma ha bisogno del campo last centro le ore, attenzione che day è un array che contiene i giorni(Object)
// e dentro dentro i giorni le hours e un Object con dentro un altro Object per ogni ora

// DBQuery.shellBatchSize = 1500

var db = db.getSiblingDB("transmission")

var start = ISODate('2016-05-01T00:00:00.000+0200')
var end = ISODate('2018-05-31T23:59:59.000+0200')

//var before = new Date()
db.remit_centrali_test_v5.aggregate(
    [{
            $match: {
                $and: [{
                        event_status: "Active"
                    },
                    {
                    	is_last: 1
                    },
                    {
                        dt_start: {
                            $lte: end
                        }
                    }, {
                        dt_end: {
                            $gte: start
                        }
                    }
                ]
            }
        },
        {
            $unwind: "$days"
        },
        {
            $match: {
                "days.is_last": 1
            }
        },
        {
            $project: {
                _id: 0,
                msg_id: 1,
                etso: 1,
                zona: 1,
                tipo: 1,
                dt_upd: 1,
                dt_start: 1,
                dt_end: 1,
                hours: "$days.hours"
            }
        },
        {
            $unwind: "$hours"
        },
        {
            $match: {
                "hours.data_hour": {
                    $gte: start,
                    $lte: end
                }
            }
        },
        {
            $match: {
                "hours.is_last": 1
            }
        },
        {
            $project: {
                msg_id: 1,
                etso: 1,
                zona: 1,
                tipo: 1,
                dt_upd: {
                    $dateToString: {
                        format: "%Y-%m-%d %H:%M:%S",
                        date: "$dt_upd",
                        timezone: "Europe/Rome"
                    }
                },
                dt_start: {
                    $dateToString: {
                        format: "%Y-%m-%d %H:%M:%S",
                        date: "$dt_start",
                        timezone: "Europe/Rome"
                    }
                },
                dt_end: {
                    $dateToString: {
                        format: "%Y-%m-%d %H:%M:%S",
                        date: "$dt_end",
                        timezone: "Europe/Rome"
                    }
                },
                dataTime: {
                    $dateToString: {
                        format: "%Y-%m-%d %H:%M:%S",
                        date: "$hours.data_hour",
                        timezone: "Europe/Rome"
                    }
                },
                giorno: {
                    $dateToString: {
                        format: "%Y-%m-%d",
                        date: "$hours.data_hour",
                        timezone: "Europe/Rome"
                    }
                },
                ora: {
                    $add: [{
                        $hour: {
                            date: "$hours.data_hour",
                            timezone: "Europe/Rome"
                        }
                    }, 1]
                },
                remit: "$hours.remit",
            },
        },
    ], {
        allowDiskUse: true,
    }
)


//print(cursor.toArray().length)
// var after = new Date()
// var execution_mills = after - before
//print(execution_mills/1000)

