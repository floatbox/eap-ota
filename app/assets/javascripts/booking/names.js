var genderNames = {
    "m": "Abram, Abrahm, Alexander, Alexandr, Aleksander, Aleksandr, Alexei, Alexey, Aleksei, Aleksey, Albert, Albyert, Anatoly, Anatoli, Anatoliy, Andrei, Andrey, Anton, Arkady, Arkadi, Arkadiy, Arseny, Arseni, Arseniy, Artyom, Artem, Artur, Artyr, Arthur, Afanasy, Afanasi, Afanasiy, Bogdan, Boris, Boric, Vadim, Badim, Valentin, Balentin, Valery, Valeri, Valeriy, Balery, Baleriy, Vasily, Vasil, Vasiliy, Vasili, Vassily, Vassiliy, Vassili, Basil, Veniamin, Viktor, Victor, Vitaly, Vitaliy, Vitali, Vlad, Vladimir, Vladislav, Vsevolod, Vyacheslav, Viacheslav, Vyatcheslav, Viatcheslav, Gavriil, Gavril, Garry, Garri, Gennady, Gennadiy, Gennadi, Georgy, George, Georgiy, Georgi, Gerasim, German, Gleb, Grigory, Grigori, Grigoriy, Grigor, David, Daniil, Danil, Denis, Dmitry, Dmitriy, Dmitri, Evgeny, Evgeniy, Evgeni, Evgen, Ewgeniy, Ewgeni, Ewgeny, Yegor, Egor, Yefim, Efim, Zakhar, Zaxar, Ivan, Ignat, Ignaty, Ignatiy, Ignati, Igor, Illarion, Ilarion, Ilia, Ilya, Iliya, Immanuil, Imanuil, Iosif, Yosif, Kirill, Kiril, Konstantin, Korney, Kornei, Corney, Cornei, Lev, Leo, Lyev, Leonid, Makar, Macar, Maxim, Maksim, Maks, Max, Marat, Mark, Marc, Matvei, Matvey, Mikhail, Mihail, Mikail, Mike, Maikl, Nestor, Nestr, Nikita, Nicita, Nikolay, Nikola, Nikolai, Nick, Nickolay, Nickolai, Nicolai, Oleg, Pavel, Pyotr, Peter, Petr, Philipp, Philip, Filip, Filipp, Phillip, Fillip, Robert, Rodion, Radion, Roman, Roma, Rostislav, Ruslan, Rouslan, Semyon, Semen, Semion, Sergei, Sergey, Serguey, Serguei, Serg, Serge, Spartak, Spartac, Stanislav, Stas, Stepan, Stepa, Shota, Taras, Tarac, Timofei, Timofey, Timur, Timour, Trofim, Eduard, Edward, Edvard, Edik, Erik, Erick, Yulian, Julian, Yury, Yuri, Yuriy, Juriy, Juri, Yakov, Iakov, Iakob, Yaroslav, Jaroslav, Givi, David, Ashot, Armen, Suren, Vahtang, Vakhtang, Ruben, Rouben, Karen, Amayak, Evlampy, Evlampiy, Evlampi, Evsei, Evsey, Elisey, Elisei, Naum, Naoum, Nikodim, Nicodim, Nickodim, Radii, Radiy, Rady, Rinat, Renat, Rashid, Rustam, Roustam, Rustem, Roustem, Stojan, Stoyan, Teodor, Tigran, Levon, Feliks, Pheliks, Felix, Phelix, Shamil, Ernest, Fuad, Damir, Domir, Aslan, Ilnur, Ravil, Adrian, Andrian, Andron, Andronik, Andranik, Zdenek, Dmitriy, Vadym, Fedor, Fyodor, Fiodor, Ashat, Nariman, Thomas, Tomas, Tsiargei, Tsiargey, Artemy, Artemi, Artemii, Artemiy, Dmytro, Vasyl, Filipp, Filip, Tobias, Danil, Danila, Daniil, Damir, Werner, Marat, Dmitrii, Bari, Adel, Innokentiy, Innokenty, Anatoly, Siarhei, Kamil, Komil, Mars, Svyatoslav, Tahir, Keith, Magomed, Magomet, Akakiy, Apti, Ilyas, Vikenty, Rafik, Andrej, Jegor, Niklas, Dobrynya, Fridrikh, Erikh, Arseniy, Arseny, Saveliy, Savely, Bogdan, Fanur, Tavris, Gagik, Jivan, Farhad, Deniel, Zanan, Gavriil, Faridun, Oleksandr, Akhmed, Samson, Arunas, Khabib, Rakhman, Vjacheslav, Andranik, Fidail, Elisey, Rahmatillo, Ulan",
    "f": "Alexandra, Aleksandra, Alina, Alisa, Alla, Alyona, Alena, Aljona, Aliona, Albina, Anastasiya, Anastasia, Anastassia, Anastassiya, Anna, Antonina, Anzhelika, Angelika, Anjelika, Anfisa, Bogdana, Bozhena, Bojena, Bogena, Vera, Valeriya, Valeria, Valerija, Varvara, Vasilisa, Vassilisa, Vladlena, Veronika, Veronica, Valentina, Viktoriya, Viktoria, Galina, Darya, Daria, Darja, Dina, Diana, Dana, Dominika, Dominica, Ekaterina, Ecaterina, Caterina, Katerina, Elena, Elizaveta, Elisaveta, Evgeniya, Evgenia, Evgenija, Ewgenia, Evelina, Elina, Ellina, Eva, Zhanna, Ganna, Zhana, Gana, Janna, Zinaida, Zina, Zoya, Zoiya, Zoia, Zoja, Zlata, Inga, Inna, Irina, Inessa,  Inesa, Izabella,  Izabela, Izolda, Isolda, Iskra, Iulia, Klara, Clara, Claudia, Klavdiya, Klavdia, Klaudiya, Klaudia, Kseniya, Ksenia, Xeniya, Xenia, Ksenija, Xenija, Kapitolina, Klementina, Kristina, Xristina, Cristina, Christina, Khristina, Lada, Larisa, Larissa, Lara, Lidiya, Lidia, Lidija, Lida, Lubov, Liybov, Liubov, Lyubov, Lybov, Ljubov, Lyubov, Luybov, Liliya, Lili, Lilia, Lilya, Lila, Lilija, Ludmila, Liudmila, Lydmila, Liydmila, Ljudmila, Lyudmila, Luydmila, Lucya, Luciya, Lucia, Margarita, Maya, Maia, Maja, Maiya, Malvina, Marta, Marina, Mariya, Maria, Masha, Nadezhda, Nadegda, Nadejda, Nadiya, Nadia, Nadya, Natalya, Natalia, Natalja, Nata, Natasha, Nelly, Nelli, Nely, Nelya, Nelja, Neli, Nina, Nika, Nica, n Nonna, Nona, Oksana, Oxana, Roksana, Roxana, Roxanna, Roksanna, Olga, Olesya, Olesia, Olesja, Alesya, Alesiya,f Alesia, Alesja, Raisa, Raissa, Rada, Rozalina, Rosalina, Rozanna, Renata, Svetlana, Sofia, Sofya, Sofja, Sonia, Sonya, Sonja, Taisia, Taisiya, Taya, Taja, Tamara, Tatyana, Tatiana, Tatjana, Tanya, Ulyana, Uliana, Uljana, Ulya, Faina, Fedosia, Fedosya, Florentina, Elvira, Elwira, Emilia, Emilya, Emilija, g Emma, Yuliya, Yulya, Yaroslava, Yana, Julija, Juliya, Julia, Violetta, Zarui, Oleksandra, Olexandra, Stefania, Stephania, Stefaniya, Stephaniya, Stefanija, Fekla, Fyokla, Fjokla, Aksinya, Aksinja, Aksinia, Kira, Cira, Shezhana, Shejana, Darya, Karina, Hanna, Nataliya, Norayr, Regina, Lana, Yulia, Uliana, Ulviya, Ulyana, Antonina, Marsel, Lana, Lina, Asya, Lika, Alsu, Letitsiya, Nazira, Nadejda, Marta, Ella, Elvira, Venera, Diana, Liana, Gulnara, Guzel, Galiya, Varsenik, Dilorom, Volha, Elvina, Mona, Zukhra, Gayane, Anzhelika, Nonna, Albina, Alsu, Dina, Karen, Zilya, Vladislava, Rezeda, Anastacia, Milana, Anaida, Angelina, Mariia, Nailya, Aigul, Anne, Aksinia, Elmira, Aida, Tursynzada, Elza, Svitlana, Aysha, Ioganna, Anisa, Iullia, Kateryna, Zinaida, Liliya"
};
