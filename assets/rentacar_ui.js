let max_mph = 120;
let max_mpg = 2.0;
let max_seats = 8;
let max_accel = 0.5;
let max_storage = 400;
let debug = false;

function setOpacity(isTrue) {
    const mainPage = document.getElementById('main');
    mainPage.style.opacity = isTrue ? 1 : 0;
}

function updateMPH(this_speed, best_speed) {
    const bar = document.getElementById('MPH');
    const tooltip = document.getElementById('MPHtooltip');
    let redValue = 0;
    let greenValue = 0;
    let blueValue = 0;
    let desiredWidth = (this_speed / best_speed) * 100;

    if (desiredWidth >= 0 && desiredWidth <= 50) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        const startColor = [192, 57, 43];
        const endColor = [255, 191, 0];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 50));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 50));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 50));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth > 50 && desiredWidth < 100) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        redValue = 255 - ((desiredWidth - 50) * 192) / 50;
        greenValue = 191 + ((desiredWidth - 50) * 35) / 50;
        blueValue = 0 + ((desiredWidth - 50) * 1) / 50;
        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 100) {
        if (desiredWidth > 100) {
            bar.style.width = 100 + '%';
        } else {
            bar.style.width = desiredWidth + '%';
        }
        // Calculate the background color based on the desired width
        redValue = 40;
        greenValue = 145;
        blueValue = 245;
        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue - 10})`;
    }

    if (desiredWidth > 0) {
        tooltip.textContent = `${this_speed} MPH`;
        tooltip.style.opacity = 1; // Set opacity to 1
    } else {
        tooltip.textContent = '';
        tooltip.style.opacity = 0; // Set opacity to 0
    }
}

function updateMPG(this_mpg, best_mpg) {
    const bar = document.getElementById('MPG');
    const bar_holder = document.getElementById('MPG_HOLDER');
    const tooltip = document.getElementById('MPGtooltip');
    let redValue = 0;
    let greenValue = 0;
    let blueValue = 0;
    let mpg_text = "_";
    let desiredWidth = (this_mpg / best_mpg) * 100.0;

    if (desiredWidth >= 0 && desiredWidth <= 33) {
        bar.style.width = desiredWidth + '%';
        mpg_text = "Good";
        // Calculate the background color based on the desired width
        let startColor = [20, 245, 40];
        let endColor = [20, 141, 40];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 50));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 50));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 50));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth > 33 && desiredWidth <= 66) {
        bar.style.width = desiredWidth + '%';
        mpg_text = "Average";
        let startColor = [20, 141, 40];
        let endColor = [40, 145, 245];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 80));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 80));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 80));
        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth > 66 && desiredWidth < 100) {
        bar.style.width = desiredWidth + '%';
        mpg_text = "Bad";
        let startColor = [255, 227, 51];
        let endColor = [245, 20, 20];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 120));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 120));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 120));
        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 100) {
        if (desiredWidth > 100) {
            bar.style.width = 100 + '%';
        } else {
            bar.style.width = desiredWidth + '%';
        }
        mpg_text = "Worst";
        // Calculate the background color based on the desired width
        redValue = 245;
        greenValue = 20;
        blueValue = 20;
        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue - 10})`;
    }

    if (desiredWidth > 0) {
        tooltip.textContent = `${mpg_text}`;
        tooltip.style.opacity = 1; // Set opacity to 1
    } else {
        tooltip.textContent = '';
        tooltip.style.opacity = 0; // Set opacity to 0
    }
}

function updateSEATS(this_seats, max_seats) {
    const bar = document.getElementById('SEATS');
    const tooltip = document.getElementById('SEATStooltip');
    let redValue = 0;
    let greenValue = 0;
    let blueValue = 0;
    let desiredWidth = (this_seats / max_seats) * 100;

    bar.style.width = desiredWidth + '%';

    if (desiredWidth > 0) {
        tooltip.textContent = `${this_seats}`;
        tooltip.style.opacity = 1; // Set opacity to 1
    } else {
        tooltip.textContent = '';
        tooltip.style.opacity = 0; // Set opacity to 0
    }
}

function updateSTORAGE(this_storage, max_storage) {
    const bar = document.getElementById('STORAGE');
    const tooltip = document.getElementById('STORAGEtooltip');
    let redValue = 0;
    let greenValue = 0;
    let blueValue = 0;
    let desiredWidth = (this_storage / max_storage) * 100;

    bar.style.width = desiredWidth + '%';

    if (desiredWidth > 0) {
        tooltip.textContent = `${this_storage} Units`;
        tooltip.style.opacity = 1; // Set opacity to 1
    } else {
        tooltip.textContent = '';
        tooltip.style.opacity = 0; // Set opacity to 0
    }
}


function updateACCEL(this_accel, max_accel) {
    const bar = document.getElementById('ACCEL');

    let redValue = 0;
    let greenValue = 0;
    let blueValue = 0;
    let desiredWidth = (this_accel / max_accel) * 100;
    if (debug) {
        console.log(desiredWidth);
    }
    if (desiredWidth >= 0 && desiredWidth < 30) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        const startColor = [255, 43, 43];
        const endColor = [255, 43, 43];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 30));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 30));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 30));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 30 && desiredWidth < 40) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        const startColor = [255, 43, 43];
        const endColor = [255, 198, 4];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 40));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 40));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 40));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 40 && desiredWidth < 60) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        const startColor = [255, 198, 4];
        const endColor = [255, 244, 4];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 60));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 60));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 60));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 60 && desiredWidth < 70) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        const startColor = [255, 244, 4];
        const endColor = [187, 255, 4];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 70));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 70));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 70));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 70 && desiredWidth < 100) {
        bar.style.width = desiredWidth + '%';
        // Calculate the background color based on the desired width
        const startColor = [187, 255, 4];
        const endColor = [43, 255, 69];
        redValue = Math.round(startColor[0] + (endColor[0] - startColor[0]) * (desiredWidth / 100));
        greenValue = Math.round(startColor[1] + (endColor[1] - startColor[1]) * (desiredWidth / 100));
        blueValue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * (desiredWidth / 100));

        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue})`;
    } else if (desiredWidth >= 100) {
        if (desiredWidth > 100) {
            bar.style.width = 100 + '%';
        } else {
            bar.style.width = desiredWidth + '%';
        }
        // Calculate the background color based on the desired width
        redValue = 40;
        greenValue = 145;
        blueValue = 245;
        bar.style.backgroundColor = `rgb(${redValue},${greenValue}, ${blueValue - 10})`;
    }
}


function updateUI(this_data) {
    let data = {};
    if (this_data == null) {
        data = {
            "mph": 150,
            "mpg": 1.1,
            "seats": 2,
            "storage": 155,
            "brand": "",
            "acceleration": 0
        };
    } else { data = this_data; }

    updateMPH(data.mph, max_mph);
    updateMPG(data.mpg, max_mpg);
    updateSEATS(data.seats, max_seats);
    updateSTORAGE(data.storage, max_storage);
    updateBRAND(data.brand);
    updateACCEL(data.acceleration, max_accel);
}


function updateBRAND(this_brand) {

    // Supported URLs
    var imageUrl = "";
    let supported_makes = {
        "ALBANY": "https://static.wikia.nocookie.net/gtawiki/images/1/1a/Albany-GTAO-Logo.png",
        "ANNIS": "https://static.wikia.nocookie.net/gtawiki/images/3/3c/Annis-Logo-GTAO.png",
        "BENEFAC": "https://static.wikia.nocookie.net/gtawiki/images/1/1d/Benefactor-GTAO-Logo.png",
        "BRAVADO": "https://static.wikia.nocookie.net/gtawiki/images/f/f3/Bravado-GTAO-Logo.png",
        "COIL": "https://static.wikia.nocookie.net/gtawiki/images/5/5a/Coil-Logo-GTAO.png",
        "CHEVAL": "https://static.wikia.nocookie.net/gtawiki/images/b/bc/Cheval-Logo-Badge-GTAO.png",
        "CRUSIER": "./assets/img/probikes_logo.png",
        "DECLASSE": "https://static.wikia.nocookie.net/gtawiki/images/d/d0/Declasse-GTAO-Logo-New.png",
        "DEWBAUCH": "./assets/img/dewbauchee.png",
        "DUNDREAR": "https://static.wikia.nocookie.net/gtawiki/images/9/9d/Dundreary-GTAO-Logo.png",
        "EMPEROR": "https://static.wikia.nocookie.net/gtawiki/images/1/16/Emperor-GTAO-Logo.png",
        "FIXTER": "./assets/img/probikes_logo.png",
        "GALLIVAN": "./assets/img/gallivanter.png",
        "GROTTI": "https://static.wikia.nocookie.net/gtawiki/images/3/35/Grotti-GTAV-Logo.png",
        "OBEY": "https://static.wikia.nocookie.net/gtawiki/images/3/38/Obey-Logo-Badge-GTAO.png",
        "OCELOT": "https://static.wikia.nocookie.net/gtawiki/images/7/76/Ocelot-GTAO-Logo.png",
        "PEGASSI": "https://static.wikia.nocookie.net/gtawiki/images/4/42/Pegassi-GTAO-Logo.png",
        "PFISTER": "https://static.wikia.nocookie.net/gtawiki/images/8/88/Pfister-GTAO-Logo.png",
        "SCORCHER": "./assets/img/probikes_logo.png",
        "UBERMACH": "./assets/img/ubermacht.png",
        "VAPID": "https://static.wikia.nocookie.net/gtawiki/images/3/33/Vapid-GTAO-Logo.png",
        "WEENY": "https://static.wikia.nocookie.net/gtawiki/images/3/3b/Weeny-GTAO-Logo.png"
    };
    if (this_brand != "") {
        imageUrl = supported_makes[this_brand.toUpperCase()] || "";
    }

    // Create an image object to get the image dimensions
    var img = new Image();
    img.src = imageUrl;

    // Set the container's background image
    var container = document.getElementById('BRAND');
    container.style.backgroundImage = 'url(' + imageUrl + ')';

    // When the image is loaded, update the container's dimensions
    img.onload = function () {
        container.style.width = img.width + "px";
        container.style.height = img.height + "px";
    };
}

window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.type === "update") {
        setOpacity(true);
        if (debug) {
            console.log(`\n\nMPH   ${item.data.mph}`);
            console.log(`MPG   ${item.data.mpg}`);
            console.log(`SEATS ${item.data.seats}`);
            console.log(`STORE ${item.data.storage}`);
            console.log(`MODEL ${item.data.model}`);
            console.log(`LABEL ${item.data.label}`);
            console.log(`PRICE ${item.data.price}`);
            console.log(`STOCK ${item.data.stock}`);
            console.log(`BRAND ${item.data.brand}`);
            console.log(`CLASS ${item.data.class}\n\n`);
            console.log(`ACCEL ${item.data.acceleration}\n\n`);
        }

        // if item.data has info, update with it, otherwise hide
        updateUI({
            "mph": item.data.mph || 100,
            "mpg": item.data.mpg || 0.0, // get this from legacyfuelredux
            "seats": item.data.seats || 4,
            "storage": item.data.storage || 180, // get this from mf-inventory
            "brand": item.data.brand || item.data.label || "",
            "acceleration": item.data.acceleration || 0
        });

    }
    if (item.type === "ui") {
        setOpacity(item.data);
        //  if ui is to be turned off, set values to 0 for a transition
        if (!item.data) {
            updateUI({
                "mph": 0,
                "mpg": 0,
                "seats": 0,
                "storage": 0,
                "brand": "",
                "acceleration": 0
            });
        }
    }
})

// setOpacity(true);
//         updateUI({
//             "mph":110,
//             "mpg": 0.0, // get this from legacyfuelredux
//             "seats": 4,
//             "storage": 180, // get this from mf-inventory
//             "brand": "GROTTI",
//           "accel": 200
//         });