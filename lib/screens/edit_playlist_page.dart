import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart'; // Para logs

class EditPlaylistPage extends StatefulWidget {
  final String playlistId; // Agora recebe o ID da playlist
  final String playlistName;
  final String? imageUrl;

  const EditPlaylistPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
    this.imageUrl,
  });

  @override
  EditPlaylistPageState createState() => EditPlaylistPageState();
}

class EditPlaylistPageState extends State<EditPlaylistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile; // Para armazenar a imagem selecionada
  String? _playlistImageUrl; // Para armazenar a URL da imagem da playlist
  String? _errorText; // Para exibir mensagens de erro no nome da playlist

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.playlistName;
    _playlistImageUrl =
        widget.imageUrl; // Inicializa com a imagem atual da playlist
  }

  // Função para atualizar o nome e imagem da playlist com validações
  void _updatePlaylist() async {
    User? user = _auth.currentUser;

    // Validação: O nome da playlist deve ter no mínimo 1 caractere
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorText = 'The playlist name must have at least 1 character.';
      });
      return;
    }

    if (user != null) {
      // ignore: unused_local_variable
      DatabaseReference userPlaylistsRef =
          _database.ref('bookshelf/${user.uid}');

      // Atualização do nome da playlist (se for diferente)
      DatabaseReference currentRef =
          _database.ref('bookshelf/${user.uid}/${widget.playlistId}');
      if (widget.playlistName != _nameController.text.trim()) {
        await currentRef.update({
          'name': _nameController.text.trim(),
        });
      }

      // Upload da nova imagem, se houver
      if (_imageFile != null) {
        String userId = user.uid;
        try {
          // Faz upload da nova imagem
          await FirebaseStorage.instance
              .ref('bookshelf/$userId/${widget.playlistId}')
              .putFile(_imageFile!);

          // Obtém a URL da nova imagem
          String downloadUrl = await FirebaseStorage.instance
              .ref('bookshelf/$userId/${widget.playlistId}')
              .getDownloadURL();

          // Atualiza a URL da imagem na Realtime Database
          await _database
              .ref('bookshelf/${user.uid}/${widget.playlistId}')
              .update({
            'image': downloadUrl,
          });

          setState(() {
            _playlistImageUrl = downloadUrl;
          });
        } catch (e) {
          Logger().e('Error uploading image: $e');
        }
      }

      if (!mounted) return; // Verifica se a página ainda está aberta

      // Exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Playlist updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating),
      );

      // Volta para a página anterior
      Navigator.pop(context, true);
    }
  }

  // Função para selecionar uma nova imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Armazena a imagem selecionada
      });
    }
  }

  // Função para remover a imagem da playlist
  Future<void> _removePlaylistImage() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    if (_playlistImageUrl != null && _playlistImageUrl!.isNotEmpty) {
      try {
        // Remove a imagem do Firebase Storage
        await FirebaseStorage.instance
            .ref('bookshelf/$uid/${widget.playlistId}')
            .delete();

        // Remove a URL da imagem no Realtime Database
        await _database
            .ref('bookshelf/$uid/${widget.playlistId}')
            .update({'image': ''});

        setState(() {
          _playlistImageUrl = ''; // Limpa a URL da playlist
          _imageFile = null; // Limpa o arquivo da imagem
        });

        if (!mounted) return; // Verifica se a página ainda está aberta
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist image removed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        Logger().e('Error removing image: $e');
        if (!mounted) return; // Verifica se a página ainda está aberta
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove playlist image.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Playlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePlaylist,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exibe a imagem atual da playlist ou um ícone padrão
            GestureDetector(
              onTap: () {
                if (widget.playlistName != 'Favorites') {
                  _pickImage(); // Permite escolher uma nova imagem ao clicar
                }
              },
              child: _imageFile != null
                  ? Image.file(_imageFile!,
                      height: 150) // Exibe a imagem escolhida
                  : (_playlistImageUrl != null && _playlistImageUrl!.isNotEmpty
                      ? Image.network(_playlistImageUrl!,
                          height: 150) // Exibe a imagem atual
                      : const Icon(Icons.book,
                          size: 100, color: Colors.blue)), // Ícone padrão
            ),
            const SizedBox(height: 8),
            if (widget.playlistName != 'Favorites')
              const Text('Tap to change image',
                  style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            if (_playlistImageUrl != null &&
                _playlistImageUrl!.isNotEmpty &&
                widget.playlistName !=
                    'Favorites') // Exibe o botão somente se houver uma imagem
              SizedBox(
                width: 150, // Largura do botão
                child: ElevatedButton(
                  onPressed: _removePlaylistImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Botão vermelho
                  ),
                  child: const Text('Remove Image',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              enabled: widget.playlistName != 'Favorites',
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                border: const OutlineInputBorder(),
                errorText: _errorText, // Exibe a mensagem de erro se houver
              ),
              onChanged: (text) {
                setState(() {
                  _errorText = null; // Limpa a mensagem de erro ao digitar
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
