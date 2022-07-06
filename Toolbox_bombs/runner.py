import os
import numpy as np

from Toolbox_bombs.immune_system_based_model import AntibodyPopulation
from Toolbox_bombs.utils import arguments, Arguments, ITER_RANGE


def main(args: Arguments):
    """
    Main method for running the BOMBS band selection algorithm.

    :param args: Parsed arguments.
    :return: None.
    """
    
    os.makedirs(args.dest_path, exist_ok=True)
    model = AntibodyPopulation(args=args)
    model.initialization()
    for iteration in range(ITER_RANGE):
        model.update_dominant_population()
        model.serialize_individuals()
        if model.stop_condition(current_generation=iteration):
            break
        print("Generation: {0}/{1}".format(iteration + 1, args.Gmax))
        #model.show_bands()
        model.serialize_individuals()
        model.active_population_selection()
        model.clone_crossover_mutation(generation_idx=iteration)
        model.update_antibody_population()
        model.end_generation()
    print("Final {0} selected bands:".format(args.bands_per_antibody))
    
    model.serialize_individuals()

    return model.show_bands()
    


if __name__ == "__main__":
    parsed_args = arguments()
    main(args=parsed_args)
