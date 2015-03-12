#!/usr/bin/env python

import Swoop
import argparse
import shutil
import EagleTools
import GadgetronConfig

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fix eagle files to make them dtd conforming")
    parser.add_argument("--file", required=True,  type=str, nargs='+', dest='file', help="files to process")
    parser.add_argument("--layers", required=False, default=[GadgetronConfig.config.CBC_STARDARD_LAYERS],  type=str, nargs=1, dest='layers', help="Layers to use")
    parser.add_argument("--force", required=False,  action="store_true", dest='force', help="Overwrite layers in file.")
    args = parser.parse_args()
    
    if args.layers:
        layers = Swoop.LibraryFile.from_file(args.layers[0])

    for f in args.file:

        ef = Swoop.EagleFile.from_file(f)

        if args.layers:
            EagleTools.normalizeLayers(ef, layers, force=args.force)
            
            #print EagleTools.ScanLibraryReferences(ef).go().get_referenced_efps()
            
        ef.write(f)
