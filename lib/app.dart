// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:paisa/config/routes.dart';
import 'package:paisa/core/common.dart';
import 'package:paisa/core/theme/app_theme.dart';
import 'package:paisa/features/account/presentation/bloc/accounts_bloc.dart';
import 'package:paisa/features/home/presentation/controller/summary_controller.dart';
import 'package:paisa/features/home/presentation/pages/home/home_cubit.dart';
import 'package:paisa/features/intro/data/models/country_model.dart';
import 'package:paisa/features/intro/domain/entities/country_entity.dart';
import 'package:paisa/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:paisa/main.dart';

class PaisaApp extends StatefulWidget {
  const PaisaApp({
    super.key,
  });

  @override
  State<PaisaApp> createState() => _PaisaAppState();
}

class _PaisaAppState extends State<PaisaApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt.get<SettingCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt.get<HomeCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt.get<AccountBloc>(),
        ),
        Provider(
          create: (context) => getIt.get<SummaryController>(),
        ),
      ],
      child: ValueListenableBuilder<Box>(
        valueListenable: settings.listenable(
          keys: [
            appColorKey,
            dynamicThemeKey,
            themeModeKey,
            calendarFormatKey,
            userCountryKey,
            appFontChangerKey,
            appLanguageKey,
            blackThemeKey,
          ],
        ),
        builder: (context, value, _) {
          final int color = value.get(
            appColorKey,
            defaultValue: 0xFF795548,
          );
          final Color primaryColor = Color(color);
          final bool isDynamic = value.get(
            dynamicThemeKey,
            defaultValue: false,
          );
          final bool isBlack = value.get(
            blackThemeKey,
            defaultValue: false,
          );
          final ThemeMode themeMode = ThemeMode.values[value.get(
            themeModeKey,
            defaultValue: 0,
          )];
          final Locale locale = Locale(
            value.get(appLanguageKey, defaultValue: 'en'),
          );
          final String fontPreference = value.get(
            appFontChangerKey,
            defaultValue: 'Outfit',
          );

          final TextTheme darkTextTheme = GoogleFonts.getTextTheme(
            fontPreference,
            ThemeData.dark().textTheme,
          );

          final TextTheme lightTextTheme = GoogleFonts.getTextTheme(
            fontPreference,
            ThemeData.light().textTheme,
          );

          return ProxyProvider0<CountryEntity>(
            lazy: true,
            update: (BuildContext context, _) {
              final Map<String, dynamic>? jsonString =
                  (value.get(userCountryKey) as Map<dynamic, dynamic>?)
                      ?.map((key, value) => MapEntry(key.toString(), value));

              final CountryEntity model =
                  CountryModel.fromJson(jsonString ?? {}).toEntity();
              return model;
            },
            child: DynamicColorBuilder(
              builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                ColorScheme lightColorScheme;
                ColorScheme darkColorScheme;
                if (lightDynamic != null && darkDynamic != null && isDynamic) {
                  lightColorScheme = lightDynamic.harmonized();
                  darkColorScheme = darkDynamic.harmonized();
                } else {
                  lightColorScheme = ColorScheme.fromSeed(
                    seedColor: primaryColor,
                  );
                  darkColorScheme = ColorScheme.fromSeed(
                    seedColor: primaryColor,
                    brightness: Brightness.dark,
                  );

                  if (isBlack) {
                    darkColorScheme = darkColorScheme.copyWith(
                      background: Colors.black,
                      surface: Colors.black,
                    );
                  }
                }

                return ScreenUtilInit(
                  designSize: MediaQuery.of(context).size,
                  minTextAdapt: true,
                  splitScreenMode: true,
                  child: MaterialApp.router(
                    locale: locale,
                    routerConfig: goRouter,
                    debugShowCheckedModeBanner: false,
                    themeMode: themeMode,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    onGenerateTitle: (BuildContext context) {
                      return context.loc.appTitle;
                    },
                    theme: appTheme(
                      context,
                      lightColorScheme,
                      fontPreference,
                      lightTextTheme,
                      ThemeData.light().dividerColor,
                      SystemUiOverlayStyle.dark,
                    ),
                    darkTheme: appTheme(
                      context,
                      darkColorScheme,
                      fontPreference,
                      darkTextTheme,
                      ThemeData.dark().dividerColor,
                      SystemUiOverlayStyle.light,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
