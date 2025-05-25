import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../image_upload.dart';
import '../models/app_models.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';
import '../utils/image_validator.dart';
import 'data_recovery_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function? onUpdateProfile;

  const ProfileScreen({Key? key, this.onUpdateProfile}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = true;
  bool _isEditing = false;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _firebaseService.getUserData();
      
      // Validate and fix corrupted profile picture if exists
      if (userData?.fotoPerfil != null) {
        final validImage = ImageValidator.validateAndFixBase64Image(userData!.fotoPerfil!);
        if (validImage != userData!.fotoPerfil && validImage != null) {
          // Update the user data with the fixed image
          final fixedUser = userData.copyWith(fotoPerfil: validImage);
          await _firebaseService.updateUserData(fixedUser);
          setState(() {
            _userData = fixedUser;
          });
        } else if (validImage == null) {
          // Remove corrupted image
          final fixedUser = userData.copyWith(fotoPerfil: null);
          await _firebaseService.updateUserData(fixedUser);
          setState(() {
            _userData = fixedUser;
          });
        } else {
          setState(() {
            _userData = userData;
          });
        }
      } else {
        setState(() {
          _userData = userData;
        });
      }
      
      if (_userData != null) {
        _nomeController.text = _userData!.nome;
        _telefoneController.text = _userData!.telefone ?? '';
        _enderecoController.text = _userData!.endereco ?? '';
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Erro ao carregar dados do usuário');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Restaurar dados originais ao cancelar edição
        if (_userData != null) {
          _nomeController.text = _userData!.nome;
          _telefoneController.text = _userData!.telefone ?? '';
          _enderecoController.text = _userData!.endereco ?? '';
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_userData != null) {
        final updatedUser = _userData!.copyWith(
          nome: _nomeController.text.trim(),
          telefone: _telefoneController.text.trim(),
          endereco: _enderecoController.text.trim(),
        );

        await _firebaseService.updateUserData(updatedUser).timeout(
          Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout ao salvar dados'),
        );

        if (mounted) {
          setState(() {
            _userData = updatedUser;
            _isEditing = false;
            _isLoading = false;
          });

          // Notificar tela pai para atualizar
          if (widget.onUpdateProfile != null) {
            widget.onUpdateProfile!();
          }

          _showSuccessMessage('Perfil atualizado com sucesso!');
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorMessage('Erro: dados do usuário não encontrados');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Erro ao atualizar perfil: ${e.toString()}');
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    // Mostrar opções ao usuário
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha uma opção',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOptionButton(
                  icon: Icons.photo_library,
                  label: 'Galeria',
                  onTap: () {
                    Navigator.pop(context);
                    _processImageSelection(false);
                  },
                ),
                _buildImageOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Câmera',
                  onTap: () {
                    Navigator.pop(context);
                    _processImageSelection(true);
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImageSelection(bool fromCamera) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final Uint8List? imageBytes = fromCamera
          ? await ImageUploadHelper.captureImage()
          : await ImageUploadHelper.pickImageFromGallery();

      if (imageBytes != null && _userData != null) {
        // Converter a imagem para Base64 com validação
        final String base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
        
        // Validar a imagem antes de salvar
        final validImage = ImageValidator.validateAndFixBase64Image(base64Image);
        if (validImage == null) {
          throw Exception('Erro ao processar a imagem. Tente novamente.');
        }
        
        // Atualizar o modelo de usuário
        final updatedUser = _userData!.copyWith(fotoPerfil: validImage);
        
        // Salvar no Firestore com timeout
        await _firebaseService.updateUserData(updatedUser).timeout(
          Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout ao salvar imagem'),
        );
        
        if (mounted) {
          // Atualizar o estado local
          setState(() {
            _userData = updatedUser;
            _isLoading = false;
          });
          
          _showSuccessMessage('Foto de perfil atualizada com sucesso!');
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Erro ao atualizar imagem: ${e.toString()}');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(ResponsiveUtil.isMobile(context) ? 16 : 
                                    ResponsiveUtil.isTablet(context) ? 20 : 
                                    ResponsiveUtil.isNotebook(context) ? 24 : 28),
              child: ResponsiveUtil.wrapWithMaxWidth(
                Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  _buildDataRecoveryButton(),
                  const SizedBox(height: 16),
                  _buildAdminButton(),
                ],
              ),
            ),
          ),
          // Overlay de loading
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Salvando...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Hero(
                  tag: 'profile',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.accentColor,
                    child: ClipOval(
                      child: _userData?.fotoPerfil != null
                          ? ImageValidator.buildSafeImage(
                              imageData: _userData!.fotoPerfil!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.primaryColor,
                              ),
                              errorWidget: Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _updateProfilePicture,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: _isEditing
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        Text(
                          _userData?.nome ?? '',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleEditMode,
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isEditing ? 'Cancelar' : 'Editar perfil',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isEditing ? AppTheme.errorColor : AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_isEditing) ...[  
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _isEditing
          ? Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações Pessoais',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Telefone
                      TextFormField(
                        controller: _telefoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: '(00) 00000-0000',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          // Formatar como (XX) XXXXX-XXXX
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            var text = newValue.text;
                            if (text.isEmpty) return newValue;
                            
                            var buffer = StringBuffer();
                            for (var i = 0; i < text.length; i++) {
                              if (i == 0) buffer.write('(');
                              buffer.write(text[i]);
                              if (i == 1) buffer.write(') ');
                              if (i == 6) buffer.write('-');
                            }
                            
                            return TextEditingValue(
                              text: buffer.toString(),
                              selection: TextSelection.collapsed(offset: buffer.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final cleanPhone = value.replaceAll(RegExp(r'\D'), '');
                            if (cleanPhone.length < 10) {
                              return 'Telefone inválido';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Endereço
                      TextFormField(
                        controller: _enderecoController,
                        decoration: InputDecoration(
                          labelText: 'Endereço completo',
                          prefixIcon: Icon(Icons.home_outlined),
                          hintText: 'Rua, número, bairro, cidade, CEP',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Pessoais',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de informações
                    _buildInfoItem(
                      Icons.phone_outlined,
                      'Telefone',
                      _userData?.telefone ?? 'Não informado',
                    ),
                    Divider(),
                    _buildInfoItem(
                      Icons.home_outlined,
                      'Endereço',
                      _userData?.endereco ?? 'Não informado',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRecoveryButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.healing,
              size: 32,
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Recuperação de Dados',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Problemas com imagens corrompidas? Use nossa ferramenta de recuperação.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataRecoveryScreen(),
                  ),
                );
              },
              icon: Icon(Icons.auto_fix_high),
              label: Text('Abrir Ferramenta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningColor,
                side: BorderSide(color: AppTheme.warningColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Painel Administrativo',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie os cupcakes do aplicativo. Adicione ou recrie produtos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminScreen(),
                  ),
                );
              },
              icon: Icon(Icons.settings),
              label: Text('Abrir Painel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}