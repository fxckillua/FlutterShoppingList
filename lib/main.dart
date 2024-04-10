import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          bodyText2: TextStyle(fontFamily: 'Roboto', color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/lists': (context) => ListPage(),
        '/about': (context) => AboutPage(),
      },
    );
  }
}

class User {
  final String name;
  final String email;
  final String password;

  User({required this.name, required this.email, required this.password});

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}

class UserList {
  static List<User> users = [];
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  void _loadSavedLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  void _saveLogin(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setString('email', email);
      prefs.setString('password', password);
    } else {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  void _login() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Empty Fields'),
            content: Text('Please fill in all fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!isValidEmail) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Email'),
            content: Text('Please enter a valid email address.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool isAuthenticated = UserList.users.any((user) =>
        user.email == email && user.password == password);

    if (isAuthenticated) {
      _saveLogin(email, password);
      Navigator.pushReplacementNamed(context, '/lists');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Authentication Failed'),
            content: Text('Invalid email or password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white), // Altera a cor do texto da caixa de texto para branco
              decoration: InputDecoration(
                hintText: 'Enter your email',
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: Colors.white), // Altera a cor do texto da caixa de texto para branco
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                Text('Remember me', style: TextStyle(color: Colors.white)), // Altera a cor do texto do checkbox para branco
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?', style: TextStyle(color: Colors.white)), // Altera a cor do texto para branco
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text('Sign Up', style: TextStyle(color: Colors.white)), // Altera a cor do texto para branco
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[9],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema: Lista de Compras',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Objetivo: Criar uma lista de Compras moderna através de um aplicativo criado em Flutter para experiência do usuário.'),
            SizedBox(height: 10),
            Text('Desenvolvedor: Luiz Eduardo C Miziara'),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signUp() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Empty Fields'),
            content: Text('Please fill in all fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!isValidEmail) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Email'),
            content: Text('Please enter a valid email address.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool emailExists = UserList.users.any((user) => user.email == email);

    if (!emailExists) {
      User newUser = User(name: name, email: email, password: password);
      UserList.users.add(newUser);
      _saveUsers();
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Email Already Exists'),
            content: Text('The entered email address is already registered.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _saveUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> usersJson =
        UserList.users.map((user) => jsonEncode(user.toJson())).toList();
    prefs.setStringList('users', usersJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<String> lists = [];

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  void _loadLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedLists = prefs.getStringList('lists');
    if (savedLists != null) {
      setState(() {
        lists = savedLists;
      });
    }
  }

  void _addList(String listName) {
    if (listName.trim().isNotEmpty) {
      setState(() {
        lists.add(listName.trim());
      });
      _saveLists();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Empty List Name'),
            content: Text('Please enter a name for the list.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _removeList(String listName) {
    setState(() {
      lists.remove(listName);
    });
    _saveLists();
  }

  void _saveLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('lists', lists);
  }

  void _editListName(String oldName) {
    final TextEditingController _editController =
        TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit List Name'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              labelText: 'List Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  int index = lists.indexOf(oldName);
                  if (index != -1) {
                    lists[index] = _editController.text.trim();
                  }
                });
                _saveLists();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Lists'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onSubmitted: _addList,
              decoration: InputDecoration(
                labelText: 'Add List',
                suffixIcon: IconButton(
                  onPressed: () {
                    _addList(_textController.text);
                    _textController.clear();
                  },
                  icon: Icon(Icons.add),
                ),
              ),
              controller: _textController,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(lists[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingListPage(listName: lists[index]),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _editListName(lists[index]);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _removeList(lists[index]);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class ShoppingListPage extends StatefulWidget {
  final String listName;

  ShoppingListPage({required this.listName});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<ShoppingItem> shoppingItems = [];

  @override
  void initState() {
    super.initState();
    _loadShoppingItems();
  }

  void _loadShoppingItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedItems = prefs.getStringList('${widget.listName}_shoppingItems');
    if (savedItems != null) {
      setState(() {
        shoppingItems = savedItems
            .map((item) => ShoppingItem.fromJson(jsonDecode(item)))
            .toList();
      });
    }
  }

  void _saveShoppingItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> itemsJson =
        shoppingItems.map((item) => item.toJson()).toList();
    List<String> itemsString =
        itemsJson.map((item) => jsonEncode(item)).toList();
    prefs.setStringList('${widget.listName}_shoppingItems', itemsString);
  }

  void _addItem(String itemName, int quantity) {
    setState(() {
      shoppingItems.add(ShoppingItem(name: itemName, quantity: quantity, isDone: false));
    });
    _saveShoppingItems();
  }

  void _toggleItem(int index) {
    setState(() {
      shoppingItems[index].isDone = !shoppingItems[index].isDone;
    });
    _saveShoppingItems();
  }

  void _deleteItem(int index) {
    setState(() {
      shoppingItems.removeAt(index);
    });
    _saveShoppingItems();
  }

  void _editItem(int index) {
    final TextEditingController _editController =
        TextEditingController(text: shoppingItems[index].name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              labelText: 'Item Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  shoppingItems[index].name = _editController.text;
                });
                _saveShoppingItems();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _searchItem() {
    showSearch(
      context: context,
      delegate: ShoppingItemSearchDelegate(shoppingItems, (String query) {
        // Implement search logic here
        print('Searching for: $query');
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        actions: [
          IconButton(
            onPressed: _searchItem,
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (value) {
                      _addItem(value, 1);
                      _textController.clear();
                    },
                    decoration: InputDecoration(
                      labelText: 'Add Item',
                    ),
                    controller: _textController,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Item with Quantity'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _textController,
                                decoration: InputDecoration(labelText: 'Item Name'),
                              ),
                              TextField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Quantity'),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                int quantity = int.tryParse(_quantityController.text) ?? 1;
                                _addItem(_textController.text, quantity);
                                _textController.clear();
                                _quantityController.clear();
                                Navigator.of(context).pop();
                              },
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Add with Quantity'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: shoppingItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${shoppingItems[index].name} (${shoppingItems[index].quantity})',
                      style: TextStyle(
                        decoration: shoppingItems[index].isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _toggleItem(index);
                          },
                          icon: Icon(Icons.check),
                          color: shoppingItems[index].isDone
                              ? Colors.green
                              : null,
                        ),
                        IconButton(
                          onPressed: () {
                            _editItem(index);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteItem(index);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

class ShoppingItem {
  String name;
  int quantity;
  bool isDone;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.isDone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'isDone': isDone,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'],
      quantity: json['quantity'],
      isDone: json['isDone'],
    );
  }
}

class ShoppingItemSearchDelegate extends SearchDelegate<String> {
  final List<ShoppingItem> shoppingItems;
  final Function(String) onSearch;

  ShoppingItemSearchDelegate(this.shoppingItems, this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final List<ShoppingItem> searchResults = query.isEmpty
        ? shoppingItems
        : shoppingItems
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].name),
          onTap: () {
            onSearch(searchResults[index].name);
            close(context, '');
          },
        );
      },
    );
  }
}