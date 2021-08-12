component {

    /**
     * Run a SQL query against the database using an existing ORM session.
     * This effectively works around both LDEV-1564 and LDEV-3659.
     *
     * @sql The SQL string to run.
     * @params An array or struct of params to bind to the query object.
     * @options Supported query options. Currently only `maxrows` is supported.
     */
    public function _queryExecute( required string sql, any params = {}, struct options = {} ){
        var query = ormGetSession().createSQLQuery( sql );

        if ( arguments.options.keyExists( "maxrows" ) ){
            query.setMaxResults( arguments.options.maxrows );
        }

        /**
         * Pass parameters to hibernate Query object.
         * TODO: May need to set a hibernate parameter type.
         * Try using `hibernateCaster.toSQLType` to get the actual Hibernate class
         * for a specific cfsqltype.
         * var hibernateCaster = createObject( "java", "org.lucee.extension.orm.hibernate.HibernateCaster" );
         * 
         * @see https://docs.jboss.org/hibernate/orm/5.4/javadocs/
         * @see https://docs.jboss.org/hibernate/orm/5.4/javadocs/org/hibernate/type/Type.html
         */
        arguments.params.each( function ( key, value ){
            if ( isSimpleValue( value ) ){
                value = {
                    value : value
                };
            }
            if ( value.keyExists( "list" ) && value.list ){
                query.setParameterList( key, listToArray( value.value ) );
            } else {
                query.setParameter( key, value.value );
            }
        });

        if ( listFirst( lCase( trim( sql ) ), " " ) == "select" ){
            var criteria = createObject( "java", "org.hibernate.internal.CriteriaImpl" );
            return query.setResultTransformer( criteria.ALIAS_TO_ENTITY_MAP )
                    .getResultList()
                    .map( function( row ) {
                        var result = {};
                        for( var key in row ){
                            result[ key ] = row[ key ];
                        }
                        return result;
                    });
        } else {
            return query.executeUpdate();
        }
    }
}