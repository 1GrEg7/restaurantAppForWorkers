import android.content.Context
import android.graphics.Typeface
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.TextView
import com.example.restaurant.R

class CustomAdapter(context: Context, resource: Int, objects: MutableList<Pair<String, MutableList<String>>>) :
    ArrayAdapter<Pair<String, MutableList<String>>>(context, resource, objects) {

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view: View = convertView ?: LayoutInflater.from(context).inflate(R.layout.list_item, parent, false)

        val productNameTextView = view.findViewById<TextView>(R.id.product_name)
        val ingredientsListTextView = view.findViewById<TextView>(R.id.ingredients_list)

        val item = getItem(position)
        val str = "${item?.first } \n"
        productNameTextView.text = str
        productNameTextView.setTypeface(null, Typeface.BOLD)
        //val str = item!!.second
//        Log.i("bbbbbbbbb",str.toString())
//        val str1 ="Масса: ${str[0]}"
//        val str2 ="Дата: ${str[1]}"+ str[1]
//        val str3 = "Срок хранения: ${str[2]}"
//        val str4 = "Ресторан: ${str[3]}"
//        val list = mutableListOf<String>(str1,str2,str3,str4)
//        Log.i("bbbbbbbbb",list.toString())
        ingredientsListTextView.text = item?.second?.joinToString("")

        return view
    }
}
