#ifndef PROCESSVIDEOFILESTASK_H
#define PROCESSVIDEOFILESTASK_H

#include "task.h"
#include <QObject>
#include <QQmlEngine>

class processvideofilestask : public Task
{
    Q_OBJECT
    QML_ELEMENT
public:
    processvideofilestask();
        // year found from name
    /*
            int appearsToBeReleaseYearInName;

            // likelihood of it being a year for a movie release

            double appearsToHaveReleaseYearInName = 0.0;

            // Break out parts of dot separated name, which is the common way files are kept as torrents, not spaces

            int partPositionInName = 0;
            int howManyPossibleYearsFound = 0;  // More than one usually means one is part of the name, or some other indication.

            QStringList FileNameDottedParts = FileName.split('.');
            for (const auto& dottedPart : FileNameDottedParts) {
                // Always file labels are 4 part years for release due to 19-- and 20--
                if (dottedPart.length() == 4) {
                    appearsToHaveReleaseYearInName = 0.1;
                    bool isDottedPartAPositiveInteger;

                    // avoid negatives or decimals
                    int dottedPartAsPositiveInteger = dottedPart.toUInt(&isDottedPartAPositiveInteger);
                    if (dottedPartAsPositiveInteger) {
                        appearsToHaveReleaseYearInName = 0.4;

                        // movies can only be "released" within an actual technical region

                        if (dottedPartAsPositiveInteger >= 1890 && isDottedPartAPositiveInteger <= QDate::currentDate().year()) {

                            // A file of a movie wouldn't have a future date in it's name.  In IMDB there are upcoming releases.

                            appearsToHaveReleaseYearInName = 0.7; // High probability, but not sure if it's release year or part of the name

                            // If first part of name, very unlikely

                            if (partPositionInName == 0) appearsToHaveReleaseYearInName/= (3.0 / (partPositionInName + 1.0)); // Like movies starting with "1984" released in 1956
                            // "2001: A Space Odyssey"  released in 1968
                            // Tamala 2010: A Punk Cat in Space" was released in 2002 So detect trailing ":" and trailing regular word strings
                            // Alien 1, 2, 3, 4, 5, 6, 7 - Sci-Fi DC SE Unrated 1979-2012 Eng Subs 720p [H264-mp4 is a folder name
                            // "Alita Battle Angel (2019)" parens make me believe
                        }
                    }
                    // is only one year present? ++appearsToHaveReleaseYearInName
                    // if surrounded by brackets, ++appearsToHaveReleaseYearInName
                }

                partPositionInName++;
            }
*/
};

#endif // PROCESSVIDEOFILESTASK_H
