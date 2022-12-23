const fs = require('fs');

const getInput = () => {
    // const input = fs.readFileSync('./day7/day7testinput.txt', 'utf8');
    const input = fs.readFileSync('./day7/day7input.txt', 'utf8');

    return input;
}

var sizedCandidadtes = [];

const listDirSizeSums = (tree) => {


    //get each folder in the tree and their sizes
    const folderSizes = Object.keys(tree).map(folder => {
        if (typeof tree[folder] === 'number') {
            //file
            return tree[folder];
        }
        else {
            //folder
            const folderSize = listDirSizeSums(tree[folder]);
            
            if (folderSize <= 100000) {
                sizedCandidadtes.push(folderSize);
            }

            return folderSize;
        }
    }
    );


    //return summed folder sizes
    return folderSizes.reduce((acc, current) => acc + current, 0);

}


const main = () => {
    const input = getInput();
    const lines = input.split('\n');

    const tree = lines.reduce((acc, currentLine, i) => {
        console.log('running', i, currentLine, acc)
        if (currentLine[0] === '$') {
            //handle command

            if (acc.currentLocation === '') {
                acc.currentLocation = currentLine.substring(5);
                return acc;
            }

            if (currentLine.substring(2, 4) === 'ls') {
                //disregard and move on - we are already tracking position
                return acc;
            }

            if (currentLine.substring(2, 4) === 'cd') {
                console.log('cd found', i, currentLine)
                if (currentLine.substring(5, 7) === '..') {
                    console.log('cd .. found', currentLine)
                    acc.currentLocation = acc.currentLocation.substring(0, acc.currentLocation.lastIndexOf('/'));
                    if (acc.currentLocation === '') {
                        acc.currentLocation = '/';
                    }
                    console.log('new location', acc.currentLocation)
                }
                else {
                    console.log('cd folder found', currentLine, 'currentloc', acc.currentLocation)
                    acc.currentLocation = acc.currentLocation + (acc.currentLocation === '/' ? '' : '/') + currentLine.substring(5);
                    console.log('new location', acc.currentLocation)
                }
                return acc;
            }
        }
        else {
            if (currentLine.substring(0, 3) === 'dir') {
                // place a dir in the tree
                const folderName = currentLine.substring(4);
                console.log('dir found', folderName, 'currentloc', acc.currentLocation)
                const folderPath = acc.currentLocation + (acc.currentLocation === '/' ? '' : '/') + folderName;
                console.log('folderPath', folderPath)
                eval(`acc.tree${folderPath.split('/').join('.')} = {}`);
                //ick yuck
            }
            else {
                //assume its a file listing
                const [fileSize, fileName] = currentLine.split(' ');
                console.log('file found', fileName, 'currentloc', acc.currentLocation)
                const filePath = acc.currentLocation + (acc.currentLocation === '/' ? '' : '/') + fileName.split('.').join('_');
                console.log('filePath', filePath)
                eval(`acc.tree${filePath.split('/').join('.')} = ${fileSize}`);
                //blech
            }

            return acc;
        }
        return acc;
    }, {currentLocation: '', tree: {}})

    console.log('tree', JSON.stringify(tree.tree))
    const sizes = listDirSizeSums(tree.tree);
    console.log('sizes', sizes)
}

main();
console.log('sizedCandidadtes', sizedCandidadtes)
console.log('sizedCandidadtes', sizedCandidadtes.reduce((acc, current) => acc + current, 0))