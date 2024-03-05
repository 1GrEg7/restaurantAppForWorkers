package com.example.restaurant

import android.health.connect.datatypes.units.Volume
import android.os.AsyncTask
import android.util.Log
import android.view.View
import java.sql.Connection
import java.sql.Date
import java.sql.DriverManager
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.Statement
import com.example.restaurant.ui.slideshow.cuisine_type
import org.postgresql.PGConnection
import java.math.BigDecimal
import java.sql.Types
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.concurrent.Executors


 class DatabaseConnectionTask{
    //   192.168.1.68 localhost  127.0.0.1 192.168.0.16
//    private val DB_URL = "jdbc:postgresql://192.168.0.16:5432/restaurantDb"
//    private val USERNAME = "postgres"
//    private val PASSWORD = "postgres"


    companion object {
        private lateinit var connection: Connection
        fun setConnection(user: String, password: String):Boolean {
            var flag = true
            val thread = Thread{
                val DB_URL = "jdbc:postgresql://192.168.207.26:5432/restaurantDb"
                val USERNAME = user //"postgres"//"cook_mone3"//"waiter_mone" //////
                val PASSWORD =  password//"postgres"//"16KcooFR3cm3" //"17KwaiFR4"// "postgres"//"17KwaiFR4"//


                try {
                    connection = DriverManager.getConnection(DB_URL, USERNAME, PASSWORD)
                    //val statement = connection.createStatement()
                    //val query = "SELECT * FROM products"
                    Log.i("55555555555", "SUCCESS!!!!")
                    flag = true
                    //connection.close()
                } catch (e: Exception) {
                    Log.i("55555555555", "FAAAAAAAIIIILLLL")
                    e.printStackTrace()
                    Log.i("55555555555", "FAAAAAAAIIIILLLL")
                    flag = false
                }
            }
            thread.start()
            thread.join()
            Log.i("flag",flag.toString())
            return flag
        }

        fun getConnection(): Connection? {
            return connection
        }
        lateinit var resultSet: ResultSet

         fun products():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM products"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){

                }
                if (this::resultSet.isInitialized){
                    while (resultSet.next()) {
                        val name = resultSet.getString("product_name").toString()
                        val weight = resultSet.getString("wieght").toString()
                        val birthData = resultSet.getString("create_data")
                        val durationLive = resultSet.getString("keep_count")
                        val restaurantName = resultSet.getString("restaurant_name")
                        Log.i("xxx", name )
                        Log.i("xxx", weight)
                        Log.i("xxx", birthData)
                        Log.i("xxx", durationLive)
                        Log.i("xxx", restaurantName)

                        val arr: MutableList<String> = mutableListOf("","","","")
                        arr.add("Масса: ${weight}\n")
                        arr.add("Дата изготовления: ${birthData}\n")
                        arr.add("Срок годности: ${durationLive}\n")
                        arr.add("Ресторан: ${restaurantName}\n")
                        list.add(Pair(name,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
             thread.start()
             thread.join()

             return list

        }

        fun dishes():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM dishes"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){
                    Log.i("sos", "AAAAAAA")
                }
                if (this::resultSet.isInitialized){
                    Log.i("sosa", "wwwAAAAAAA")
                    while (resultSet.next()) {
                        Log.i("sosa", "wwwAAAAAAAinto")
                        val name = resultSet.getString("dish_name").toString()
                        val weight = resultSet.getString("weight").toString()
                        val composition = resultSet.getString("composition")
                        val callories = resultSet.getString("callories")
                        val restaurantName = resultSet.getString("restaurant_name")
                        val cuisine = resultSet.getString("cuisine").toString()
                        Log.i("TTTTT", cuisine )
                        Log.i("TTTTT", name )
                        Log.i("TTTTT", weight)
                        Log.i("TTTTT", composition)
                        Log.i("TTTTT", callories)
                        Log.i("TTTTT", restaurantName)

                        val arr: MutableList<String> = mutableListOf("","","","","")
                        arr.add("Масса: ${weight}\n")
                        arr.add("Ингридиенты: ${composition}\n")
                        arr.add("Калории: ${callories}\n")
                        arr.add("Кухня: ${cuisine}\n")
                        arr.add("Ресторан: ${restaurantName}\n")

                        list.add(Pair(name,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
            thread.start()
            thread.join()

            return list

        }




        fun workers():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM workers"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){
                    Log.i("sos", "AAAAAAA")
                }
                if (this::resultSet.isInitialized){
                    Log.i("sosa", "wwwAAAAAAA")
                    while (resultSet.next()) {
                        Log.i("sosa", "wwwAAAAAAAinto")
                        val ID = resultSet.getString("ID_worker").toString()
                        val Surname = resultSet.getString("Surname").toString()
                        val Lastname = resultSet.getString("Lastname")
                        val Sex = resultSet.getString("Sex")
                        val Birth_date = resultSet.getString("Birth_date")
                        val Name = resultSet.getString("Name").toString()
                        val Phone_number = resultSet.getString("Phone_number").toString()
                        val Post = resultSet.getString("Post").toString()
                        val Waste_hours = resultSet.getString("Waste_hours").toString()


                        val arr: MutableList<String> = mutableListOf("","","","","")
                        val str = "${Surname} ${Name} ${Lastname}"
                        arr.add("ID: ${ID}\n")
                       // arr.add("ФИО: \n")
                        arr.add("Должность: ${Post}\n")
                        arr.add("Пол: ${Sex}\n")
                        arr.add("Дата рождения: ${Birth_date}\n")
                        arr.add("Телефон: ${Phone_number}\n")
                        arr.add("Отработанные часы: ${Waste_hours}\n")

                        list.add(Pair(str,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
            thread.start()
            thread.join()

            return list

        }


        fun clients():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM clients"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){
                    Log.i("sos", "AAAAAAA")
                }
                if (this::resultSet.isInitialized){
                    Log.i("sosa", "wwwAAAAAAA")
                    while (resultSet.next()) {
                        Log.i("sosa", "wwwAAAAAAAinto")
                        val ID = resultSet.getString("Card_id").toString()
                        val Email = resultSet.getString("Email").toString()
                        val Spend_money = resultSet.getString("Spend_money")
                        val Points = resultSet.getString("Points")
                        val Name = resultSet.getString("Name").toString()
                        val Phone_number = resultSet.getString("Phone_number").toString()



                        val arr: MutableList<String> = mutableListOf("","","","","")
                        val str = Name
                         arr.add("Имя: ${str} \n")
                        arr.add("ID: ${ID}\n")

                        arr.add("Email: ${Email}\n")
                        arr.add("Последняя покупка: ${Spend_money}р\n")
                        arr.add("Бонусы: ${Points}\n")
                        arr.add("Телефон: ${Phone_number}\n")

                        list.add(Pair(str,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
            thread.start()
            thread.join()

            return list

        }

        fun drinks():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM drinks"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){
                    Log.i("sos", "AAAAAAA")
                }
                if (this::resultSet.isInitialized){
                    Log.i("sosa", "wwwAAAAAAA")
                    while (resultSet.next()) {
                        Log.i("sosa", "wwwAAAAAAAinto")
                        val Drink_name  = resultSet.getString("Drink_name").toString()
                        val Volume = resultSet.getString("Volume").toString()
                        val Composition = resultSet.getString("Composition")
                        val Alcohol_degree = resultSet.getString("Alcohol_degree")
                        val Restaurant_name  = resultSet.getString("Restaurant_name").toString()




                        val arr: MutableList<String> = mutableListOf("","","","","")
                        val str = Drink_name
                        arr.add("Название: ${str} \n")
                        arr.add("Объем: ${Volume}\n")

                        arr.add("Состав: ${Composition}\n")
                        arr.add("Градус: ${Alcohol_degree}\n")
                        arr.add("Название ресторана: ${Restaurant_name}\n")

                        list.add(Pair(str,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
            thread.start()
            thread.join()

            return list

        }

        fun restaurants():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM restaurants"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){
                    Log.i("sos", "AAAAAAA")
                }
                if (this::resultSet.isInitialized){
                    Log.i("sosa", "wwwAAAAAAA")
                    while (resultSet.next()) {
                        Log.i("sosa", "wwwAAAAAAAinto")
                        val Restaurant_name  = resultSet.getString("Restaurant_name").toString()
                        val Seats_count = resultSet.getString("Seats_count").toString()
                        val Address = resultSet.getString("Address")
                        val Worker_count = resultSet.getString("Worker_count")
                        val Earnings  = resultSet.getString("Earnings").toString()




                        val arr: MutableList<String> = mutableListOf("","","","","")
                        val str = Restaurant_name
                        arr.add("Название: ${str} \n")
                        arr.add("Колличество мест: ${Seats_count}\n")

                        arr.add("Адрес: ${Address}\n")
                        arr.add("Кол. работников: ${Worker_count}\n")
                        arr.add("Заработок заведения: ${Earnings}\n")

                        list.add(Pair(str,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
            thread.start()
            thread.join()

            return list

        }


        fun suppliers():MutableList< Pair<String,MutableList<String>> >{
            var list:MutableList< Pair<String,MutableList<String>> > = mutableListOf()// mutableListOf<List<String>>()
            val thread = Thread{
                //var list = List<String>(2)
                val statement: Statement
                val query:String

                try {
                    statement = getConnection()!!.createStatement()
                    query = "SELECT * FROM suppliers"
                    resultSet = statement.executeQuery(query)

                }catch (e:Exception){
                    Log.i("sos", "AAAAAAA")
                }
                if (this::resultSet.isInitialized){
                    Log.i("sosa", "wwwAAAAAAA")
                    while (resultSet.next()) {
                        Log.i("sosa", "wwwAAAAAAAinto")
                        val Company_name   = resultSet.getString("Company_name").toString()
                        val Delivery_type = resultSet.getString("Delivery_type").toString()
                        val Supplier_type  = resultSet.getString("Supplier_type")
                        val Restaurant_name = resultSet.getString("Restaurant_name")



                        val arr: MutableList<String> = mutableListOf("","","","","")
                        val str = Company_name
                        arr.add("Название: ${str} \n")
                        arr.add("Тип доставки: ${Delivery_type}\n")

                        arr.add("Тип поставщика: ${Supplier_type}\n")
                        arr.add("Имя ресторана: ${Restaurant_name}\n")


                        list.add(Pair(str,arr))
                    }
                }else{
                    list = mutableListOf()
                }
            }
            thread.start()
            thread.join()

            return list

        }


        fun addProduct(product_name: String, wieght: Double,create_data: Date ,keep_count: Int,restaurant_name: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query = "INSERT INTO products(product_name, wieght, create_data, keep_count, restaurant_name) values(?, ?, ?, ?, ?)"
                    val preparedStatement: PreparedStatement = connection.prepareStatement(query)


                    preparedStatement.setString(1,product_name)
                    preparedStatement.setDouble(2, wieght)
                    preparedStatement.setDate(3, create_data)
                    preparedStatement.setInt(4, keep_count.toInt())
                    preparedStatement.setString(5, restaurant_name)
                    preparedStatement.executeUpdate()

                    preparedStatement.close()
                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteProduct(product_name: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement = connection.createStatement()
                val query: String

                try {
                    //statement = getConnection()!!.createStatement()
                    query = "DELETE FROM products WHERE product_name ='${product_name}'"
                    var b = statement.executeUpdate(query)
                    flag = b != 0
                    //Log.i("kkkkkkkkk", b.toString())
                    statement.close()


                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }



        //val pgConnection = connection.unwrap(PGConnection::class.java)

// Проверяем доступность PGConnection.customTypeMap
//        if (pgConnection.javaClass.declaredMethods.any { it.name == "customTypeMap" }) {
//            val typeMapField = pgConnection.javaClass.getDeclaredField("customTypeMap").apply { isAccessible = true }
//            val customTypeMap = typeMapField.get(pgConnection) as MutableMap<String, Class<*>>
//
//
//
//// Регистрируем ваш тип данных под именем "my_custom_type"
//            customTypeMap.put("my_custom_type", YourCustomType::class.java)
//        } else {
//// Если PGConnection.customTypeMap недоступен, используем PGConnection.typeMap
//            val typeMapField = pgConnection.javaClass.getDeclaredField("typeMap").apply { isAccessible = true }
//            val typeMap = typeMapField.get(pgConnection) as MutableMap<String, Class<*>>
//
//
//
//// Регистрируем ваш тип данных под именем "my_custom_type"
//            typeMap.put("my_custom_type", YourCustomType::class.java)
//        }
//



//        val pgConnection = connection.unwrap(PGConnection::class.java)
//        val typeMap = pgConnection.javaClass
//
//        typeMap.put("cuisine_type", cuisine_type::class.java)
//        val name = resultSet.getString("dish_name").toString()
//        val weight = resultSet.getString("weight").toString()
//        val composition = resultSet.getString("composition")
//        val callories = resultSet.getString("callories")
//        val restaurantName = resultSet.getString("restaurant_name")
//        val cuisine = resultSet.getString("cuisine").toString()
        fun addDish(dish_name: String, weight: Int, composition: String , callories: Int, restaurant_name: String, cuisine: cuisine_type):Boolean {

            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query = "INSERT INTO dishes(dish_name, weight, composition , callories, restaurant_name, cuisine) values(?, ?, ?, ?, ?, ?)"
                    val preparedStatement: PreparedStatement = connection.prepareStatement(query)

                    preparedStatement.setString(1,dish_name)
                    preparedStatement.setInt(2,  weight)
                    preparedStatement.setString(3, composition)
                    preparedStatement.setInt(4, callories)
                    preparedStatement.setString(5, restaurant_name)
                    preparedStatement.setObject(6, cuisine, Types.OTHER)
                    preparedStatement.executeUpdate()

                    preparedStatement.close()
                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteDish(dish_name: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement = connection.createStatement()
                val query: String

                try {
                    //statement = getConnection()!!.createStatement()
                    query = "DELETE FROM dishes WHERE dish_name ='${dish_name}'"
                    var b = statement.executeUpdate(query)
                    flag = b != 0
                    //Log.i("kkkkkkkkk", b.toString())
                    statement.close()


                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }


//        val ID = resultSet.getString("Card_id").toString()
//        val Email = resultSet.getString("Email").toString()
//        val Spend_money = resultSet.getString("Spend_money")
//        val Points = resultSet.getString("Points")
//        val Name = resultSet.getString("Name").toString()
//        val Phone_number = resultSet.getString("Phone_number").toString()


        fun addClient(name: String, ID: String, Email: String , Spend_money: BigDecimal, restaurant_name: String, Points: BigDecimal, Phone_number: String):Boolean {

            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query1: String
                val query2: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query1 = "INSERT INTO clients(card_id, name, email , phone_number, spend_money , points) values(?, ?, ?, ?, ?, ?)"
                    query2 = "INSERT INTO clientsrestaurants(restaurant_name,card_id) values(?, ?)"
                    val preparedStatement1: PreparedStatement = connection.prepareStatement(query1)
                    val preparedStatement2: PreparedStatement = connection.prepareStatement(query2)

                    preparedStatement1.setString(1,ID)
                    preparedStatement1.setString(2,  name)
                    preparedStatement1.setString(3, Email)
                    preparedStatement1.setString(4, Phone_number)
                    preparedStatement1.setBigDecimal(5, Spend_money)
                    preparedStatement1.setBigDecimal(6, Points)
                    preparedStatement1.executeUpdate()

                    preparedStatement1.close()

                    preparedStatement2.setString(1,  restaurant_name)
                    preparedStatement2.setString(2,  ID)
                    preparedStatement2.executeUpdate()

                    preparedStatement2.close()

                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteClient(ID: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement1: Statement = connection.createStatement()
                val query1: String

                val statement2: Statement = connection.createStatement()
                val query2: String

                try {
                    query2 = "DELETE FROM clientsrestaurants WHERE card_id ='${ID}'"
                    val b2 = statement2.executeUpdate(query2)
                    statement2.close()

                    //statement = getConnection()!!.createStatement()
                    query1 = "DELETE FROM clients WHERE card_id ='${ID}'"
                    val b = statement1.executeUpdate(query1)

                    //Log.i("kkkkkkkkk", b.toString())
                    statement1.close()



                    if (b ==1 && b2 ==1){
                        flag = true
                    }


                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }


        fun addDrink(Drink_name: String, volume: Int, composition: String , alcohol_degree: Int, restaurant_name: String):Boolean {

            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query = "INSERT INTO drinks(drink_name, volume, composition , alcohol_degree, restaurant_name) values(?, ?, ?, ?, ?)"
                    val preparedStatement: PreparedStatement = connection.prepareStatement(query)

                    preparedStatement.setString(1,Drink_name)
                    preparedStatement.setInt(2,  volume)
                    preparedStatement.setString(3, composition)
                    preparedStatement.setInt(4, alcohol_degree)
                    preparedStatement.setString(5, restaurant_name)
                    preparedStatement.executeUpdate()

                    preparedStatement.close()
                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteDrink(drink_name: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement = connection.createStatement()
                val query: String

                try {
                    //statement = getConnection()!!.createStatement()
                    query = "DELETE FROM drinks WHERE drink_name ='${drink_name}'"
                    var b = statement.executeUpdate(query)
                    flag = b != 0
                    //Log.i("kkkkkkkkk", b.toString())
                    statement.close()


                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }


        fun addSupplier(supplier_name: String, delivery_type: String , supplier_type: String, restaurant_name: String):Boolean {

            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query = "INSERT INTO suppliers(company_name, delivery_type, supplier_type,restaurant_name) values(?, ?, ?, ?)"
                    val preparedStatement: PreparedStatement = connection.prepareStatement(query)

                    preparedStatement.setString(1,supplier_name)
                    preparedStatement.setString(2,  delivery_type)
                    preparedStatement.setString(3, supplier_type)
                    preparedStatement.setString(4, restaurant_name)
                    preparedStatement.executeUpdate()

                    preparedStatement.close()
                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteSupplier(company_name: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement = connection.createStatement()
                val query: String

                try {
                    //statement = getConnection()!!.createStatement()
                    query = "DELETE FROM suppliers WHERE company_name ='${company_name}'"
                    var b = statement.executeUpdate(query)
                    flag = b != 0
                    //Log.i("kkkkkkkkk", b.toString())
                    statement.close()


                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun addRestaurant(restaurant_name: String, seats_count: Int , address: String, worker_count: Int, earnings: BigDecimal):Boolean {

            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query = "INSERT INTO restaurants(restaurant_name, seats_count, address,worker_count,earnings ) values(?, ?, ?, ?, ?)"
                    val preparedStatement: PreparedStatement = connection.prepareStatement(query)

                    preparedStatement.setString(1,restaurant_name)
                    preparedStatement.setInt(2,  seats_count)
                    preparedStatement.setString(3, address)
                    preparedStatement.setInt(4, worker_count)
                    preparedStatement.setBigDecimal(5, earnings)
                    preparedStatement.executeUpdate()

                    preparedStatement.close()
                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteRestaurant(restaurant_name: String):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement = connection.createStatement()
                val query: String

                try {
                    //statement = getConnection()!!.createStatement()
                    query = "DELETE FROM restaurants WHERE restaurant_name ='${restaurant_name}'"
                    var b = statement.executeUpdate(query)
                    flag = b != 0
                    //Log.i("kkkkkkkkk", b.toString())
                    statement.close()


                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }



        fun addWorker(ID: Int, name: String, surname: String , lastname: String, sex: String, birthday: Date, phone_number: String, waste_hours: Int, premium:Int, post: String,restaurant_name: String):Boolean {

            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement: Statement
                val query1: String
                val query2: String
                try {
                    //statement = getConnection()!!.createStatement()
                    query1 = "INSERT INTO workers(id_worker, name, surname ,lastname, sex, birth_date,phone_number, waste_hours,premium,post) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    query2 = "INSERT INTO work_place(restaurant_name,id_worker) values(?, ?)"
                    val preparedStatement1: PreparedStatement = connection.prepareStatement(query1)
                    val preparedStatement2: PreparedStatement = connection.prepareStatement(query2)

                    preparedStatement1.setInt(1,ID)
                    preparedStatement1.setString(2,  name)
                    preparedStatement1.setString(3, surname)
                    preparedStatement1.setString(4, lastname)
                    preparedStatement1.setString(5, sex)
                    preparedStatement1.setDate(6, birthday)
                    preparedStatement1.setString(7, phone_number)
                    preparedStatement1.setInt(8, waste_hours)
                    preparedStatement1.setInt(9, premium)
                    preparedStatement1.setString(10, post)
                    preparedStatement1.executeUpdate()

                    preparedStatement1.close()

                    preparedStatement2.setString(1,  restaurant_name)
                    preparedStatement2.setInt(2,  ID)
                    preparedStatement2.executeUpdate()

                    preparedStatement2.close()

                    flag = true

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }

        fun deleteWorker(ID: Int):Boolean {
            var flag = true
            val thread = Thread {
                flag = true
                //var list = List<String>(2)
                val statement1: Statement = connection.createStatement()
                val query1: String

                val statement2: Statement = connection.createStatement()
                val query2: String

                try {
                    query2 = "DELETE FROM work_place WHERE id_worker =${ID}"
                    val b2 = statement2.executeUpdate(query2)
                    statement2.close()

                    //statement = getConnection()!!.createStatement()
                    query1 = "DELETE FROM workers WHERE id_worker =${ID}"
                    val b = statement1.executeUpdate(query1)

                    //Log.i("kkkkkkkkk", b.toString())
                    statement1.close()

                    if (b ==1 && b2 ==1){
                        flag = true
                    }

                } catch (e: Exception) {
                    flag = false
                    Log.i("sosoooooooooos", "AAAAAAA")
                    e.printStackTrace()
                    Log.i("sosoooooooooos", "AAAAAAA")
                }
            }
            thread.start()
            thread.join()
            return flag
        }


        fun check(){
            Log.i("1!!!","JJJJJJJJJJJJJJJJJ")
        }
    }




    //private lateinit var connection: Connection
//    fun conect(user: String, password: String): Boolean{
//        var flag = true
//        val thread = Thread{
//            val DB_URL = "jdbc:postgresql://192.168.0.16:5432/mobileDb"
//            val USERNAME = user //"postgres"
//            val PASSWORD = password //"postgres"
//
//
//            try {
//                connection = DriverManager.getConnection(DB_URL, USERNAME, PASSWORD)
//                //val statement = connection.createStatement()
//                //val query = "SELECT * FROM products"
//                Log.i("55555555555", "SUCCESS!!!!")
//                flag = true
//                //connection.close()
//            } catch (e: Exception) {
//                Log.i("55555555555", "FAAAAAAAIIIILLLL")
//                e.printStackTrace()
//                Log.i("55555555555", "FAAAAAAAIIIILLLL")
//                flag = false
//            }
//        }
//        thread.start()
//        thread.join()
//        Log.i("flag",flag.toString())
//        return flag
//    }






    fun greg(){
        Log.i("PPPP", "999")
    }




    //    override fun doInBackground(vararg voids: Void): Connection? {
//        try {
//            Class.forName("org.postgresql.Driver")
//            return DriverManager.getConnection(DB_URL, USERNAME, PASSWORD)
//        } catch (e: Exception) {
//            Log.i("22222222","FAAAAAAAIIIILLLL")
//            e.printStackTrace()
//            Log.i("22222222","FAAAAAAAIIIILLLL")
//            return null
//        }
//    }


//    override fun onPostExecute(connection: Connection?) {
//        if (connection != null) {
//            Log.i("111111111", "SUCCESS!!!!")
//            val executor = Executors.newSingleThreadExecutor()
//            executor.execute {
//                try {
//                    val statement = connection.createStatement()
//                    val query = "SELECT * FROM products"
//                    val resultSet = statement.executeQuery(query)
//                    while (resultSet.next()) {
//                        val id = resultSet.getString("product_id")
//                        val name = resultSet.getString("product_name")
//                        val type = resultSet.getString("product_type")
//                        Log.i("00000000000", id)
//                        Log.i("PPPPPP", name)
//                        println("ID: $id Name: $name, type: $type")
//                    }
//                    connection.close()
//                } catch (e: Exception) {
//                    Log.i("55555555555", "FAAAAAAAIIIILLLL")
//                    e.printStackTrace()
//                    Log.i("55555555555", "FAAAAAAAIIIILLLL")
//                }
//            }
//        }
//    }

}