set_unless[:neo4j][:version] = "1.2"
set_unless[:neo4j][:database_location] = "/srv/neo4j/graphdb"
set_unless[:neo4j][:webserver_port] = "7474"
set_unless[:neo4j][:enable_ha] = false
set_unless[:neo4j][:ha_port] = "6001"
set_unless[:neo4j][:ip_address] = "localhost"
