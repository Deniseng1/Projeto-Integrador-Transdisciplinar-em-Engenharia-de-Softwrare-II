import 'package:flutter/material.dart';

class ResponsiveUtil {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 950;

  static bool isNotebook(BuildContext context) =>
      MediaQuery.of(context).size.width >= 950 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getCupcakeGridCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 650) {
      return 2; // Mobile: 2 cards por linha
    } else if (width < 950) {
      return 3; // Tablet: 3 cards por linha
    } else if (width < 1200) {
      return 4; // Notebook: 4 cards por linha (aumentado para melhor uso do espaço)
    } else {
      return 5; // Desktop: 5 cards por linha (aumentado para telas maiores)
    }
  }

  static double getCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return 260; // Altura do card em mobile
    } else if (isTablet(context)) {
      return 280; // Altura do card em tablet
    } else if (isNotebook(context)) {
      return 290; // Altura do card em notebook
    } else {
      return 300; // Altura do card em desktop
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 0.7; // Mais alto que largo em mobile
    } else if (isTablet(context)) {
      return 0.75; // Proporção para tablet
    } else if (isNotebook(context)) {
      return 0.8; // Proporção para notebook (ajustado para melhor visualização)
    } else {
      return 0.85; // Mais quadrado em desktop
    }
  }

  static EdgeInsetsGeometry getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else if (isNotebook(context)) {
      return const EdgeInsets.symmetric(horizontal: 28);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static Widget wrapWithMaxWidth(Widget child, {double maxWidth = 1400.0}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
  
  // Helper para obter espaçamento horizontal responsivo para notebooks
  static double getNotebookHorizontalSpacing() {
    return 24.0; // Espaçamento horizontal otimizado para notebooks
  }
  
  static double getFontSize(BuildContext context, double mobileSize) {
    if (isMobile(context)) {
      return mobileSize;
    } else if (isTablet(context)) {
      return mobileSize * 1.1; // 10% maior em tablet
    } else if (isNotebook(context)) {
      return mobileSize * 1.15; // 15% maior em notebook
    } else {
      return mobileSize * 1.2; // 20% maior em desktop
    }
  }
  
  // Helper para obter o tamanho de um banner responsivo
  static double getBannerHeight(BuildContext context) {
    if (isMobile(context)) {
      return 180; // Altura para mobile
    } else if (isTablet(context)) {
      return 240; // Altura para tablet
    } else if (isNotebook(context)) {
      return 280; // Altura para notebook
    } else {
      return 300; // Altura para desktop
    }
  }
  
  // Helper para obter padding responsivo
  static EdgeInsetsGeometry getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else if (isNotebook(context)) {
      return const EdgeInsets.all(28);
    } else {
      return const EdgeInsets.all(32);
    }
  }
  
  // Helper para obter tamanho de botão responsivo
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 44; // Altura para mobile
    } else if (isTablet(context)) {
      return 48; // Altura para tablet
    } else if (isNotebook(context)) {
      return 50; // Altura para notebook
    } else {
      return 52; // Altura para desktop
    }
  }
}