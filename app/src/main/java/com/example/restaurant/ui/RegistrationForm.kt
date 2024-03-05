package com.example.restaurant.ui

import android.content.Intent
import android.os.Bundle
import android.text.Html
import android.util.Log
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat.startActivity
import androidx.core.os.trace
import com.example.restaurant.MainActivity
import com.example.restaurant.databinding.RegistrationFormBinding
import com.example.restaurant.DatabaseConnectionTask
import java.util.stream.Stream


class RegistrationForm: AppCompatActivity() {

    fun screening(str: String): String{
        val removedString = str.replace(Regex("[\\s'\\$()<>;:?/\\\\|^%@!&*]"), "")
        return removedString
    }


    private lateinit var binding2: RegistrationFormBinding
    private lateinit var userField :TextView
    private lateinit var passwordField :TextView
    private lateinit var databaseConnectionTask: DatabaseConnectionTask

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding2 = RegistrationFormBinding.inflate(layoutInflater)
        setContentView(binding2.root)
        userField = binding2.editTextLogin
        passwordField = binding2.editTextPassword
        //databaseConnectionTask = DatabaseConnectionTask()


    }

    fun signUp(view: View) {
        val user = screening(userField.text.toString())

        val password = screening(passwordField.text.toString())
        Log.i("999999",user)
        Log.i("----", screening("P ()<> | | || oo!&?"))

        Log.i("999999",password)
        //databaseConnectionTask.conect(user,password)
        try {
            var conectionSucces = DatabaseConnectionTask.setConnection(user,password)
            if (conectionSucces){
                val myIntent = Intent(this, MainActivity::class.java)
                startActivity(myIntent)
            }


        }catch (e: Exception){
            Log.i("22222222","FAAAAAAAIIIILLLL")
            e.printStackTrace()
            Log.i("22222222","FAAAAAAAIIIILLLL")
        }

    }



}