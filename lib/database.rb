module Database

    def query(sql)
        ActiveRecord::Base.connection.query(sql)
    end

    def execute(sql)
        ActiveRecord::Base.connection.execute(sql)
    end


end



