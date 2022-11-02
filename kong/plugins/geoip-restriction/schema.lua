local typedefs = require "kong.db.schema.typedefs"


return {
  name = "geoip-restriction",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { allow = { type = "array", elements = { type = "string" }, }, },
          { deny = { type = "array", elements = { type = "string" }, }, },
          { status = { type = "number", required = false } },
          { message = { type = "string", required = false } },
        },
      },
    },
  },
  entity_checks = {
    { at_least_one_of = { "config.allow", "config.deny" }, },
  },
}

