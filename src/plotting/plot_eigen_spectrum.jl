function __plot_eigen_spectrum(dir_to_save::String, eigvals::Array{Float64,1})
    #build x, y axis; y being the eigenspectrum and x it's enumeration
    ploting_axes = _create_ploting_axes(eigvals)

    #compute linear fit 
    params = compute_linear_fit_params(ploting_axes[2])
    
    full_file_path = _create_eigenspectrum_plot_file_path(dir_to_save,beta)
    
    #persist graph if doesn't exist
    if !isfile(full_file_path)
        #plot styling
        plt = plot(ploting_axes[1],ploting_axes[2], label=L"{Eig val}_n", legend=false, xscale=:log10, yscale=:log10,alpha=0.2)
        #linear fit
        plot!(u -> exp10(params[1] + params[2]*log10(u)),minimum(ploting_axes[1]),maximum(ploting_axes[1]), xscale=:log10,yscale=:log10,lc=:red)
        
        title!("Eigen spectrum,beta = $(round(beta,digits=3)), beta_fit = $(round(-params[2],digits=3))")
        xlabel!(L"n")
        ylabel!("Eigen spectrum")
        
        #file saving
        savefig(plt, full_file_path)
    end
end

function plot_eigen_spectrum(dir_to_save::String,M::Matrix{Float64})
    eigvals = compute_eigvals(M)
    __plot_eigen_spectrum(dir_to_save,eigvals)
end

function plot_eigen_spectra()
   
end